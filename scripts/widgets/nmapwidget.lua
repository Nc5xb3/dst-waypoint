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
	MapWidget.noffset = Vector3(0,0,0)
	MapWidget.ndragpos = Vector3(0,0,0)
	MapWidget.nclickable = true
	MapWidget.nmapicons = MapWidget:AddChild(NPanel("NMapIconRoot"))
	MapWidget.ntooltip = MapWidget:AddChild(NMapIconTooltip(MapWidget))

	if TheFrontEnd.NMapIconTemplateManager ~= nil then
		for i,v in pairs(TheFrontEnd.NMapIconTemplateManager.templates) do
			if v.widget ~= nil then
				local icon = MapWidget.nmapicons:AddChild(NMapIcon())
				icon.widget = icon:AddChild(v.widget(MapWidget.nmapicons))
				icon:SetWorldPosition(v.worldposition)
			end
		end
	end

	local OldOnUpdate = MapWidget.OnUpdate
	function MapWidget:OnUpdate(dt, ...)
		-- Start of copied code from old MapWidget:OnUpdate with slight change to keep track of offset and initial drag position
		if not self.shown then return end
		
		if TheInput:IsControlPressed(CONTROL_PRIMARY) then
			local pos = TheInput:GetScreenPosition()
			if self.lastpos then
				local scale = 0.25
				local dx = scale * ( pos.x - self.lastpos.x )
				local dy = scale * ( pos.y - self.lastpos.y )
				self:Offset( dx, dy )
			end

			self.lastpos = pos
			if not self.ndragpos then
				self.ndragpos = pos
			end
		else
			self.lastpos = nil
			self.ndragpos = nil
			self.nclickable = true
		end
		-- End of copied code

		-- If dragging while on an interactive widget, after drag exceeds a number of pixels, then make widget not clickable
		if self.ndragpos and self.lastpos then
			local ox = self.ndragpos.x - self.lastpos.x
			local oy = self.ndragpos.y - self.lastpos.y
			local dist = math.sqrt(ox*ox + oy*oy)
			if dist > DRAG_MAX_DIST then
				self.nclickable = false
			end
		end

		-- Update position of all map icons and tooltip
		local tooltip = ""
		for i,v in pairs(self.nmapicons.children) do
			local wp = v:GetWorldPosition()
			local sx,sy = self:GetWorldToScreenPosition(wp.x,wp.z)
			v:UpdatePosition(sx,sy,1/self:GetZoom())
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
		
		OldOnUpdate(self, dt, ...)
	end

	function MapWidget:GetWorldToScreenPosition(x,z)
		-- Instead of using TheInput:GetScreenPosition (which is affected by camera smoothing)
		-- TheCamera is used for sharp correct coordinates
		local c = TheCamera.targetpos
		-- Calculate the offset of the target from camera (note: the numbers are angled!)
		local ox = x - c.x
		local oz = z - c.z
		-- Angle offset to correctly translate world angle to screen angle (better if using games constant somewhere)
		local angle = TheCamera:GetHeadingTarget()*DEGREES + PI
		-- Calculate distance and angle
		local wd = math.sqrt(ox*ox + oz*oz)/self.minimap:GetZoom()*4.5
		local wa = math.atan2(ox, oz) + angle
		-- Covert to screen + offset corrdinates
		local screenWidth, screenHeight = TheSim:GetScreenSize()
		local cx = screenWidth*.5 + self.noffset.x*4.5
		local cy = screenHeight*.5 + self.noffset.y*4.5
		local sx = cx - wd*math.cos(wa)
		local sz = cy + wd*math.sin(wa)
		return sx, sz
	end

	function MapWidget:GetZoom()
		return self.minimap:GetZoom()
	end
	
	local OldOffset = MapWidget.Offset
	function MapWidget:Offset(dx, dy, ...)
		self.noffset.x = self.noffset.x + dx
		self.noffset.y = self.noffset.y + dy
		OldOffset(self, dx, dy, ...)
	end
	
	local OldOnShow = MapWidget.OnShow
	function MapWidget:OnShow(...)
		self.noffset.x = 0
		self.noffset.y = 0
		OldOnShow(self, ...)
	end
	
	local OldOnZoomIn = MapWidget.OnZoomIn
	function MapWidget:OnZoomIn(...)
		local zoom1 = self.minimap:GetZoom()
		OldOnZoomIn(self, ...)
		local zoom2 = self.minimap:GetZoom()
		if self.shown then
			self.noffset = self.noffset*zoom1/zoom2
		end
	end

	local OldOnZoomOut = MapWidget.OnZoomOut
	function MapWidget:OnZoomOut(...)
		local zoom1 = self.minimap:GetZoom()
		OldOnZoomOut(self, ...)
		local zoom2 = self.minimap:GetZoom()
		if self.shown and zoom1 < 20 then
			self.noffset = self.noffset*zoom1/zoom2
		end
	end

end

return NMapWidget