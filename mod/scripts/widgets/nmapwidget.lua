--[[
NMapWidget
By Nc5xb3
Overriding MapWidget to include a NMapIconTemplateManager for custom widgets on minimap
Courtesy to rezecib and his Global Positions mod for introducing a way to augment the MapWidget
]]

local NPanel = require "widgets/npanel"
local NMapIcon = require "widgets/nmapicon"
local NMapIconTooltip = require "widgets/nmapicontooltip"

local DRAG_MAX_DIST = 10

-- Controller: the map has no mouse, only a crosshair in the screen centre.
-- The icon closest to it (within this many pixels at 720p) counts as hovered.
local CONTROLLER_HOVER_RADIUS = 40
local CONTROLLER_HOVER_SCALE = 1.4

local function NMapWidget(MapWidget)
	MapWidget.ndragpos = nil
	MapWidget.nclickable = true
	MapWidget.nmapicons = MapWidget:AddChild(NPanel("NMapIconRoot"))
	MapWidget.ntooltip = MapWidget:AddChild(NMapIconTooltip(MapWidget))

	if TheFrontEnd.NMapIconTemplateManager ~= nil then
		for i,v in pairs(TheFrontEnd.NMapIconTemplateManager.templates) do
			-- A template's widget function may return nil to skip the icon
			local widget = v.widget ~= nil and v.widget(MapWidget.nmapicons) or nil
			if widget ~= nil then
				local icon = MapWidget.nmapicons:AddChild(NMapIcon())
				icon.widget = icon:AddChild(widget)
				icon:SetWorldPosition(v.worldposition)
			end
		end
	end

	local OldOnUpdate = MapWidget.OnUpdate
	function MapWidget:OnUpdate(dt, ...)
		-- Let the game handle dragging/panning itself (its drag scale and drag
		-- threshold changed in later DST updates, so we no longer copy that code).
		OldOnUpdate(self, dt, ...)

		if not self.shown then return end

		-- Track how far the mouse moved while held, so an icon is not "clicked"
		-- at the end of a map drag.
		if TheInput:IsControlPressed(CONTROL_PRIMARY) then
			local pos = TheInput:GetScreenPosition()
			if not self.ndragpos then
				self.ndragpos = pos
			else
				local ox = self.ndragpos.x - pos.x
				local oy = self.ndragpos.y - pos.y
				if ox*ox + oy*oy > DRAG_MAX_DIST*DRAG_MAX_DIST then
					self.nclickable = false
				end
			end
		else
			self.ndragpos = nil
			self.nclickable = true
		end

		-- Controller hover only on the fullscreen map (not e.g. a HUD minimap
		-- widget from another mod), and only while it's the active screen
		local controllerHover = TheInput:ControllerAttached()
			and self.mapscreen ~= nil and self.mapscreen.name == "MapScreen"
			and TheFrontEnd:GetActiveScreen() == self.mapscreen
		local screenW, screenH = TheSim:GetScreenSize()
		local hoverRadius = CONTROLLER_HOVER_RADIUS * screenH / 720
		local hovered, hoveredDistSq, hoveredX, hoveredY = nil, hoverRadius * hoverRadius, 0, 0

		-- Update position of all map icons and tooltip
		local tooltip = ""
		local scale = 1/self:GetZoom()
		for i,v in pairs(self.nmapicons.children) do
			local wp = v:GetWorldPosition()
			local sx,sy = self:GetWorldToScreenPosition(wp.x,wp.z)
			v:UpdatePosition(sx,sy,scale)
			v:SetClickable(self.nclickable)

			if controllerHover then
				local dx, dy = sx - screenW * .5, sy - screenH * .5
				local dsq = dx * dx + dy * dy
				if dsq <= hoveredDistSq then
					hovered, hoveredDistSq, hoveredX, hoveredY = v, dsq, sx, sy
				end
			elseif self.nclickable then
				local t = v:GetTooltip()
				if t then
					tooltip = t
				end
			end
		end

		-- Controller: no floating tooltip (the icon already shows its name, and
		-- the travel action is in the map's help bar, see NMapScreen)
		self:NSetControllerHover(hovered)
		if hovered ~= nil then
			hovered:UpdatePosition(hoveredX, hoveredY, scale * CONTROLLER_HOVER_SCALE)
			hovered:MoveToFront()
		end

		if tooltip ~= nil and tooltip ~= "" then
			if self.ntooltip.text:GetString() ~= tooltip then
				self.ntooltip.text:SetString(tooltip)
			end
		elseif self.ntooltip.text:GetString() ~= "" then
			self.ntooltip.text:SetString("")
		end
	end

	-- Controller: the icon under the crosshair gets the button's focus look
	-- (MapScreen reads self.nhovered to travel there, see NMapScreen)
	function MapWidget:NSetControllerHover(icon)
		if icon == self.nhovered then
			return
		end
		local old = self.nhovered
		self.nhovered = icon
		local oldButton = old ~= nil and old.widget ~= nil and old.widget.button or nil
		if oldButton ~= nil and oldButton.inst:IsValid() then
			oldButton:OnLoseFocus()
		end
		local button = icon ~= nil and icon.widget ~= nil and icon.widget.button or nil
		if button ~= nil then
			button:OnGainFocus() -- also plays the hover sound
		end
	end

	-- World (x, z) -> screen pixels (origin bottom-left).
	-- Uses the game's own minimap projection, which accounts for camera heading
	-- (rotation), zoom and pan offset - including zoom-to-cursor - so icons line up
	-- exactly with the map. WorldPosToMapPos returns -1..1 from the screen centre.
	function MapWidget:GetWorldToScreenPosition(x,z)
		local mx, my = self.minimap:WorldPosToMapPos(x, z, 0)
		local screenWidth, screenHeight = TheSim:GetScreenSize()
		return (mx + 1) * screenWidth * .5, (my + 1) * screenHeight * .5
	end

	if MapWidget.GetZoom == nil then
		function MapWidget:GetZoom()
			return self.minimap:GetZoom()
		end
	end

end

return NMapWidget