--[[
NMapScreen
Post-construct for the fullscreen MapScreen: with a controller, Y travels to
the waypoint under the map crosshair (NMapWidget marks it as nhovered), when
"click flag to travel" is on. The help bar shows the action.
]]

local TRAVEL_CONTROL_NAME = "CONTROL_MENU_MISC_2" -- Y; keep in sync with nmapwidget.lua

local function TravelControl()
	return rawget(_G, TRAVEL_CONTROL_NAME)
end

-- The hovered waypoint's travel function, if any
local function HoveredTravel(screen)
	if not TheInput:ControllerAttached() then
		return nil
	end
	local icon = screen.minimap ~= nil and screen.minimap.nhovered or nil
	local root = icon ~= nil and icon.widget or nil
	if root == nil or root.travel == nil then
		return nil
	end
	return root.travel, root.waypointName
end

local function NMapScreen(MapScreen)
	local OldOnControl = MapScreen.OnControl
	MapScreen.OnControl = function(self, control, down, ...)
		if control == TravelControl() then
			local travel = HoveredTravel(self)
			if travel ~= nil then
				if down then
					self.ntravelpressed = true
				elseif self.ntravelpressed then
					self.ntravelpressed = nil
					-- Close the map like the game's own map actions do, then walk
					local playercontroller = self.owner ~= nil and self.owner.components.playercontroller or nil
					TheFrontEnd:PopScreen(self)
					if playercontroller ~= nil then
						playercontroller._hack_ignore_held_controls = 0.1
						playercontroller._hack_ignore_ups_for = {}
					end
					travel()
				end
				return true
			end
			self.ntravelpressed = nil
		end
		return OldOnControl(self, control, down, ...)
	end

	local OldGetHelpText = MapScreen.GetHelpText
	MapScreen.GetHelpText = function(self, ...)
		local text = OldGetHelpText ~= nil and OldGetHelpText(self, ...) or ""
		local travel, name = HoveredTravel(self)
		if travel ~= nil and TravelControl() ~= nil then
			local strs = STRINGS.WAYPOINT.UI.INDICATOR.BUTTON
			local extra = TheInput:GetLocalizedControl(TheInput:GetControllerID(), TravelControl()) .. " " ..
				strs.PREFIX_TRAVELTO .. (name or "") .. strs.SUFFIX_TRAVELTO
			text = text ~= "" and (text .. "  " .. extra) or extra
		end
		return text
	end
end

return NMapScreen
