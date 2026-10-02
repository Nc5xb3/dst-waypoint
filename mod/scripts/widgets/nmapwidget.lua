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

		-- Update position of all map icons and tooltip
		local tooltip = ""
		local scale = 1/self:GetZoom()
		for i,v in pairs(self.nmapicons.children) do
			local wp = v:GetWorldPosition()
			local sx,sy = self:GetWorldToScreenPosition(wp.x,wp.z)
			v:UpdatePosition(sx,sy,scale)
			v:SetClickable(self.nclickable)

			if self.nclickable then
				local t = v:GetTooltip()
				if t then
					tooltip = t
				end
			end
		end

		if tooltip ~= nil and tooltip ~= "" then
			if self.ntooltip.text:GetString() ~= tooltip then
				self.ntooltip.text:SetString(tooltip)
			end
		elseif self.ntooltip.text:GetString() ~= "" then
			self.ntooltip.text:SetString("")
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