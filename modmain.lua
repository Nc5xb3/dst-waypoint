-- Load essentials
local require = GLOBAL.require

-- FOR MOD DEVELOPMENT --
-- GLOBAL.CHEATS_ENABLED = true
-- require "debugkeys"
-- c_reset() after changes

-- Load Assets
Assets =
{
	Asset("ATLAS", "images/icon.xml"),
	Asset("IMAGE", "images/icon.tex"),
	Asset("ATLAS", "images/flag.xml"),
	Asset("IMAGE", "images/flag.tex"),
	Asset("ATLAS", "images/flagmini.xml"),
	Asset("IMAGE", "images/flagmini.tex"),
	-- COMPATIBILITY below
	Asset("ATLAS", "images/white.xml"),
	Asset("IMAGE", "images/white.tex"),
	-- STYLES below
	Asset("ATLAS", "images/npanel.xml"),
	Asset("IMAGE", "images/npanel.tex"),
	Asset("ATLAS", "images/npanelbg.xml"),
	Asset("IMAGE", "images/npanelbg.tex"),
	Asset("ATLAS", "images/ninput.xml"),
	Asset("IMAGE", "images/ninput.tex"),
	Asset("ATLAS", "images/nline.xml"),
	Asset("IMAGE", "images/nline.tex"),
	Asset("ATLAS", "images/nuiwp.xml"),
	Asset("IMAGE", "images/nuiwp.tex"),
}

AddMinimapAtlas("images/flagmini.xml")

PrefabFiles = {
	"flagplacer",
}

-- Adding cross-compatibility between DS and DST
-- local Compat = require "util/compatibility"
local DST = GLOBAL.TheSim:GetGameID() == "DST"
local function ThePlayer()
	if DST then
		return GLOBAL.ThePlayer
	end
	return GLOBAL.GetPlayer()
end
local function CompatibilityImageButton()
	if DST then
		return require "widgets/imagebutton"
	end
	return require "widgets/dstimagebutton"
end

-- Load mod configurations
local LOC = GetModConfigData("LOCALIZATION_MOD_WAYPOINT", "en")
if type(LOC) == 'table' then
	LOC = LOC.data
end
local SKIN = GetModConfigData("SKIN_MOD_WAYPOINT", 1)
local SHOW_WAYPOINT_INDICATORS = GetModConfigData("SHOW_WAYPOINT_INDICATORS", true)
local ENABLE_CONTROLLER_SUPPORT = GetModConfigData("ENABLE_CONTROLLER_SUPPORT", true)
local KEY = GetModConfigData("KEY_TOGGLE_MOD_WAYPOINT", 120)
local KEY_INDICATORS = GetModConfigData("KEY_TOGGLE_MOD_WAYPOINT_INDICATORS", 0)
local WIDTH = GetModConfigData("WIDTH_MOD_WAYPOINT", 360)
local HEIGHT = GetModConfigData("HEIGHT_MOD_WAYPOINT", 480)
local COLOUR_VARIETY = GetModConfigData("COLOUR_PALETTE_VARIETY", 8)
local HIDE_HUD_ICON = GetModConfigData("HIDE_HUD_ICON_WAYPOINT", false)
if type(HIDE_HUD_ICON) ~= 'boolean' then
	HIDE_HUD_ICON = HIDE_HUD_ICON == 1
end
local DISABLE_CUSTOM_MAP_ICONS = GetModConfigData("DISABLE_CUSTOM_MAP_ICONS_WAYPOINT", false)
if type(DISABLE_CUSTOM_MAP_ICONS) ~= 'boolean' then
	DISABLE_CUSTOM_MAP_ICONS = DISABLE_CUSTOM_MAP_ICONS == 1
end
local ALWAYS_SHOW_MP = GetModConfigData("ALWAYS_SHOW_MP_WAYPOINT", false)
if type(ALWAYS_SHOW_MP) ~= 'boolean' then
	ALWAYS_SHOW_MP = ALWAYS_SHOW_MP == 1
end
local SHOW_COORDINATES = GetModConfigData("SHOW_COORDINATES", false)
local DISABLE_AUTO_TRAVEL = GetModConfigData("DISABLE_AUTO_TRAVEL", false)

if not DST then
	ALWAYS_SHOW_MP = false
end

-- Load localization
modimport("stringlocalization_" .. LOC .. ".lua")
STRINGS = GLOBAL.STRINGS
STRINGS.WAYPOINT = WAYPOINT

-----v MAIN v-----
local function IsScreenBusy()
	return not (ThePlayer() and type(ThePlayer()) == 'table' and
		ThePlayer().HUD and type(ThePlayer().HUD) == 'table' and
		TheFrontEnd:GetActiveScreen() and
		TheFrontEnd:GetActiveScreen().name and
		type(TheFrontEnd:GetActiveScreen().name) == 'string' and
		TheFrontEnd:GetActiveScreen().name == 'HUD')
end

local function GetScaledScreen(controls)
	local screenWidth, screenHeight = GLOBAL.TheSim:GetScreenSize()
	local hudscale = controls.top_root:GetScale()
	local screenGridW = screenWidth / hudscale.x
	local screenGridH = screenHeight / hudscale.y
	-- print("[waypoint] width " .. screenWidth .. " / " .. hudscale.x)
	-- print("[waypoint] height " .. screenHeight .. " / " .. hudscale.y)
	return screenGridW, screenGridH
end

-- Post Construct and Key Handlers
local function AddMod(controls)
	controls.inst:DoTaskInTime(0, function()
		local MainWp = require "mainwp"
		local NIndicatorManager = require "widgets/nindicatormanager"
		controls.waypoint = controls.top_root:AddChild(
			MainWp(
				WIDTH,
				HEIGHT,
				SKIN,
				SHOW_COORDINATES,
				DISABLE_AUTO_TRAVEL,
				COLOUR_VARIETY
			)
		)
		controls.waypoint:SetConfiguration(ALWAYS_SHOW_MP)
		controls.waypoint.im = controls.top_root:AddChild(NIndicatorManager())
		controls.waypoint.im:MoveToBack()
		controls.waypoint:Hide()

		-- Continuous update to player's position
		local base_OnUpdate = controls.OnUpdate
		controls.OnUpdate = function(self, dt)
			base_OnUpdate(self, dt)
			if controls.waypoint:IsVisible() then
				local p = Point(ThePlayer().Transform:GetWorldPosition())
				controls.waypoint:OnUpdate_PlayerPosition(p)
			end
		end
		
		-- Toggle key for GUI
		GLOBAL.TheInput:AddKeyDownHandler(KEY, function()
			if IsScreenBusy() then
				-- print("[waypoint] GUI can't be toggled")
				return
			end

			-- if shift is down, toggle marker visibility
			if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then
				if controls.waypoint then
					controls.waypoint:ToggleMarkerMode()
				end
			else
				-- else toggle gui visibility
				if controls.waypoint:IsVisible() then
					controls.waypoint:Hide()
				else
					controls.waypoint:Show()
				end
			end
		end)
		
		-- Toggle key for markers
		GLOBAL.TheInput:AddKeyDownHandler(KEY_INDICATORS, function()
			if IsScreenBusy() then
				-- print("[waypoint] markers can't be toggled")
				return
			end

			if controls.waypoint then
				controls.waypoint:ToggleMarkerMode()
			end
		end)

		-- No point of showing icon if controller connected
		local controller_mode = GLOBAL.TheInput:ControllerAttached()

		-- HUD Icon
		if not HIDE_HUD_ICON and not controller_mode then
			local ImageButton = CompatibilityImageButton()
			controls.waypoint_icon = controls.top_root:AddChild(
				ImageButton("images/icon.xml","icon.tex","icon.tex","icon.tex")
			)
			local sw, sh = GetScaledScreen(controls)
			local posX = sw/2
			local posY = -sh
			local offX, offY = controls.waypoint_icon:GetSize()

			controls.waypoint_icon:SetTooltip(STRINGS.WAYPOINT.UI.HUD.TOOLTIP .. 
				"\n(" .. string.upper(string.char(KEY)) .. ")")
			controls.waypoint_icon:SetPosition(posX - offX/2,posY + offY*1.2,0)
			controls.waypoint_icon:SetNormalScale(.7)
			controls.waypoint_icon:SetFocusScale(.8)
			controls.waypoint_icon:SetOnClick(function()
				if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then
					if controls.waypoint then
						controls.waypoint:ToggleMarkerMode()
					end
				else
					-- else toggle gui visibility
					if controls.waypoint:IsVisible() then
						controls.waypoint:Hide()
					else
						controls.waypoint:Show()
					end
				end
			end)
		end

		-- Update hud size and position on event (best to update through event than overriding PlayerProfile.GetHUDSize)
		if DST then
			ThePlayer().HUD.inst:ListenForEvent("refreshhudsize", function(hud, scale)
				if controls.waypoint then
					controls.waypoint:SetScale(scale)
				end
				if controls.waypoint_icon then
					local sw, sh = GetScaledScreen(controls)
					local posX = sw/2
					local posY = -sh
					local offX, offY = controls.waypoint_icon:GetSize()

					controls.waypoint_icon:SetPosition(posX - offX/2,posY + offY*1.2,0)
				end
			end)
			
    		ThePlayer().HUD.inst:PushEvent("refreshhudsize", TheFrontEnd:GetHUDScale())
		end

		if controller_mode and ENABLE_CONTROLLER_SUPPORT then
			local function GetActiveScreenName()
				local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
				return screen and screen.name or ""
			end
			local function IsPauseScreen()
				return GetActiveScreenName():find("PauseScreen") ~= nil
			end
			local function IsScoreboardScreen()
				return GetActiveScreenName():find("PlayerStatusScreen") ~= nil
			end
			
			GLOBAL.TheInput:AddControlHandler(
				GLOBAL.CONTROL_OPEN_CRAFTING, -- left trigger
				DST and 
					function(down)
						-- if DST, only trigger on scoreboard screen
						if not down and IsScoreboardScreen() then
							if controls.waypoint then
								controls.waypoint:ToggleMarkerMode()
							end
						end
					end
				or
					function(down)
						-- if DS, only trigger on main screen
						if not down and IsPauseScreen() then
							if controls.waypoint then
								controls.waypoint:ToggleMarkerMode()
							end
						end
					end
			)
			GLOBAL.TheInput:AddControlHandler(
				GLOBAL.CONTROL_OPEN_INVENTORY, -- right trigger
				DST and
					function(down)
						-- if DST, only trigger on scoreboard screen
						if not down and IsScoreboardScreen() then
							controls.waypoint:Add()
						end
					end
				or
					function(down)
						-- if DS, only trigger on main screen
						if not down and IsPauseScreen() then
							controls.waypoint:Add()
						end
					end
			)
			GLOBAL.TheInput:AddControlHandler(
				GLOBAL.CONTROL_SCROLLFWD, -- right shoulder
				DST and
					function(down)
						-- if DST, only trigger on scoreboard screen
						if not down and IsScoreboardScreen() then
							local point = Point(ThePlayer().Transform:GetWorldPosition())
							local wid = controls.waypoint:ClosestWaypointAt(point, .7)
							if wid then
								controls.waypoint:Remove(wid)
							end
						end
					end
				or
					function(down)
						-- if DS, only trigger on main screen
						if not down and IsPauseScreen() then
							local point = Point(ThePlayer().Transform:GetWorldPosition())
							local wid = controls.waypoint:ClosestWaypointAt(point, .7)
							if wid then
								controls.waypoint:Remove(wid)
							end
						end
					end
			)
		end

		if SHOW_WAYPOINT_INDICATORS and controls.waypoint then
			controls.waypoint:ToggleMarkerMode()
		end

	end)
end

-- * Curious to know if TheFrontEnd is an appropriate place to add my NMapIconTemplateManager
if not DISABLE_CUSTOM_MAP_ICONS then
	local NMapIconTemplateManager = require "widgets/nmapicontemplatemanager"
	require "frontend"
	local OldFrontEnd_ctor = GLOBAL.FrontEnd._ctor
	GLOBAL.FrontEnd._ctor = function(TheFrontEnd, ...)
		OldFrontEnd_ctor(TheFrontEnd, ...)
		if TheFrontEnd.NMapIconTemplateManager == nil then
			TheFrontEnd.NMapIconTemplateManager = NMapIconTemplateManager()
		end
	end
end
-- if not DISABLE_CUSTOM_MAP_ICONS then
-- 	AddClassPostConstruct("frontend", function(FrontEnd)
-- 		local NMapIconTemplateManager = require "widgets/nmapicontemplatemanager"
-- 		if FrontEnd.NMapIconTemplateManager == nil then
-- 			FrontEnd.NMapIconTemplateManager = NMapIconTemplateManager()
-- 		end
-- 	end)
-- end

-- AddSimPostInit(function() ModInit() end)
AddClassPostConstruct("widgets/controls", AddMod)
AddClassPostConstruct("widgets/mapwidget", require "widgets/nmapwidget")
-- AddClassPostConstruct("screens/mapscreen", function(MapScreen)
-- 	print("okay")
-- end)