-- Load essentials
local require = GLOBAL.require

-- FOR MOD DEVELOPMENT --
-- GLOBAL.CHEATS_ENABLED = true
-- require "debugkeys"
-- require("waypointdevtools")(env) -- TEST deploy only (dev/scripts): test mode (god/creative/invisible) + c_wpscatter(), c_wpring(), c_wpclear()
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

-- Helper function to normalize boolean config values
local function NormalizeBoolean(value, default)
	if type(value) == 'boolean' then
		return value
	end
	return value == 1 or (default and value ~= 0)
end

-- Helper function to extract data from table config values
local function ExtractConfigData(value)
	if type(value) == 'table' and value.data ~= nil then
		return value.data
	end
	return value
end

-- Load mod configurations
-- Localization: "auto" follows the game's language; anything else is a fixed choice.
-- Keys are the mod's stringlocalization_<code>.lua files.
local SUPPORTED_LOCALIZATIONS = { en = true, ru = true, jp = true, zh = true, ko = true, pt = true }
-- Game locale code (LOC.GetLocaleCode) -> mod file code
local GAME_LOCALE_TO_MOD = {
	en = "en",
	ru = "ru",
	ja = "jp",
	zh = "zh", zhr = "zh", zht = "zh", -- Traditional falls back to Simplified until a zht file exists
	ko = "ko",
	pt = "pt",
}

local function DetectGameLocalization()
	local gameLoc = GLOBAL.rawget(GLOBAL, "LOC")
	if type(gameLoc) == "table" and type(gameLoc.GetLocaleCode) == "function" then
		local ok, code = GLOBAL.pcall(gameLoc.GetLocaleCode)
		if ok and type(code) == "string" then
			return GAME_LOCALE_TO_MOD[code] or "en"
		end
	end
	return "en"
end

local LOC = ExtractConfigData(GetModConfigData("LOCALIZATION_MOD_WAYPOINT", "auto"))
if LOC == nil or LOC == "auto" then
	LOC = DetectGameLocalization()
end
if not SUPPORTED_LOCALIZATIONS[LOC] then
	LOC = "en"
end
print("[waypoint] localization: " .. LOC)
local SKIN = GetModConfigData("SKIN_MOD_WAYPOINT", 1)
-- Controller support is always on (its modinfo option is commented out; set
-- this to false to switch every controller hook off)
local ENABLE_CONTROLLER_SUPPORT = true
-- Keybinds are now configured in-game via the keybind dialog
-- Defaults: toggle_ui = 120 (X), toggle_indicators = 0 (None)
local KEY = 120  -- Default to X key
local KEY_INDICATORS = 0  -- Default to None
local COLOUR_VARIETY = GetModConfigData("COLOUR_PALETTE_VARIETY", 8)
local ALWAYS_SHOW_MP = NormalizeBoolean(GetModConfigData("ALWAYS_SHOW_MP_WAYPOINT", false), false)

if not DST then
	ALWAYS_SHOW_MP = false
end

local PersistentData = require "persistentdata"

-- In-game settings (Configurations dialog). Saved per client and applied instantly.
-- These used to be modinfo options; see MigrateOldModinfoSettings.
local WAYPOINT_SETTINGS = {
	show_hud_button = true,
	map_icons = "all",        -- "all" | "visible" (hide hidden waypoints) | "off"
	sort = "manual",          -- "manual" (your order, Up/Down) | "distance" (closest first)
	show_coordinates = false,
	click_to_travel = true,
	indicator_shape = "ellipse", -- "square" | "rectangle" | "circle" | "ellipse"
	indicator_names = "hover",     -- "always" | "hover" (indicator name only while hovering)
	indicator_area_size = 80,      -- percent, 30-100 in steps of 10 (renamed from indicator_size so early test saves reset)
	window_width = 360,            -- waypoint window size, WINDOW_SIZE_MIN-MAX in steps of WINDOW_SIZE_STEP
	window_height = 480,           -- (were the modinfo options WIDTH/HEIGHT_MOD_WAYPOINT)
}
-- Defaults for "Reset to default" (copied before saved settings are loaded)
local DEFAULT_WAYPOINT_SETTINGS = {}
for k, v in pairs(WAYPOINT_SETTINGS) do DEFAULT_WAYPOINT_SETTINGS[k] = v end
local WINDOW_SIZE_MIN, WINDOW_SIZE_MAX, WINDOW_SIZE_STEP = 300, 600, 60
local MAP_ICON_MODES = { all = true, visible = true, off = true }
local IndicatorArea = require "indicatorarea"

local function SanitizeSetting(key, value)
	if key == "map_icons" then
		return MAP_ICON_MODES[value] and value or nil
	elseif key == "sort" then
		return (value == "manual" or value == "distance") and value or nil
	elseif key == "indicator_shape" then
		return IndicatorArea:IsValidShape(value) and value or nil
	elseif key == "indicator_names" then
		return (value == "always" or value == "hover") and value or nil
	elseif key == "indicator_area_size" then
		return IndicatorArea:ClampSize(value)
	elseif key == "window_width" or key == "window_height" then
		if type(value) ~= "number" then return nil end
		value = WINDOW_SIZE_MIN + math.floor((value - WINDOW_SIZE_MIN) / WINDOW_SIZE_STEP + .5) * WINDOW_SIZE_STEP
		return math.max(WINDOW_SIZE_MIN, math.min(WINDOW_SIZE_MAX, value))
	elseif WAYPOINT_SETTINGS[key] ~= nil and type(value) == "boolean" then
		return value
	end
	return nil
end

local settingsData = PersistentData("waypoint_settings")

local function SaveSettings()
	settingsData:SetValue("settings", WAYPOINT_SETTINGS)
	settingsData:Save()
end

local function OldModinfoValue(name)
	local ok, v = GLOBAL.pcall(GetModConfigData, name, true)
	if ok then return v end
	return nil
end

-- Window size used to be the modinfo options WIDTH/HEIGHT_MOD_WAYPOINT
local function MigrateOldWindowSize()
	local w = SanitizeSetting("window_width", ExtractConfigData(OldModinfoValue("WIDTH_MOD_WAYPOINT")))
	local h = SanitizeSetting("window_height", ExtractConfigData(OldModinfoValue("HEIGHT_MOD_WAYPOINT")))
	if w ~= nil then WAYPOINT_SETTINGS.window_width = w end
	if h ~= nil then WAYPOINT_SETTINGS.window_height = h end
end

-- First run only: carry over values from the old modinfo options if the game still has them
local function MigrateOldModinfoSettings()
	local old = OldModinfoValue
	MigrateOldWindowSize()
	local v = old("HIDE_HUD_ICON_WAYPOINT")
	if v ~= nil then WAYPOINT_SETTINGS.show_hud_button = not NormalizeBoolean(v, false) end
	v = old("DISABLE_CUSTOM_MAP_ICONS_WAYPOINT")
	if v ~= nil and NormalizeBoolean(v, false) then WAYPOINT_SETTINGS.map_icons = "off" end
	v = old("SHOW_COORDINATES")
	if v ~= nil then WAYPOINT_SETTINGS.show_coordinates = NormalizeBoolean(v, false) end
	v = old("DISABLE_AUTO_TRAVEL")
	if v ~= nil then WAYPOINT_SETTINGS.click_to_travel = not NormalizeBoolean(v, false) end
end

local settingsLoaded = false
settingsData:Load(function()
	settingsLoaded = true
	local saved = settingsData:GetValue("settings")
	if type(saved) == "table" then
		for key in pairs(WAYPOINT_SETTINGS) do
			local value = SanitizeSetting(key, saved[key])
			if value ~= nil then
				WAYPOINT_SETTINGS[key] = value
			end
		end
		-- Saved before window size moved here: take it from the old modinfo options
		if saved.window_width == nil and saved.window_height == nil then
			MigrateOldWindowSize()
		end
	else
		MigrateOldModinfoSettings()
	end
	SaveSettings()
end)
if not settingsLoaded then
	-- No saved settings file yet
	MigrateOldModinfoSettings()
	SaveSettings()
end
IndicatorArea:Set(WAYPOINT_SETTINGS.indicator_shape, WAYPOINT_SETTINGS.indicator_area_size)
IndicatorArea.namesOnHover = WAYPOINT_SETTINGS.indicator_names == "hover"

-- Keybind persistence and API
local keybindData = PersistentData("waypoint_keybinds")

local WAYPOINT_KEYBINDS = {
	toggle_ui = KEY,
	toggle_indicators = KEY_INDICATORS,
}
local DEFAULT_KEYBINDS = {
	toggle_ui = KEY,
	toggle_indicators = KEY_INDICATORS,
}

local function SaveKeybinds()
	keybindData:SetValue("keybinds", WAYPOINT_KEYBINDS)
	keybindData:Save()
end

-- Validate that a keycode is safe to use as a keybind
-- Returns true if valid, false otherwise
local function IsValidKeycode(keycode)
	-- Allow 0 (None)
	if keycode == 0 then
		return true
	end
	
	-- Check if keycode is within valid range
	if type(keycode) ~= "number" or keycode < 0 or keycode > 255 then
		return false
	end
	
	-- Only allow letters A-Z (both uppercase 65-90 and lowercase 97-122)
	local isUppercase = keycode >= 65 and keycode <= 90
	local isLowercase = keycode >= 97 and keycode <= 122
	if not (isUppercase or isLowercase) then
		return false
	end
	
	-- All valid letter keycodes (65-90, 97-122) are safe for string.char
	return true
end

keybindData:Load(function()
	local saved = keybindData:GetValue("keybinds")
	if type(saved) == "table" then
		-- Validate and sanitize saved keybinds
		if saved.toggle_ui ~= nil then
			if IsValidKeycode(saved.toggle_ui) then
				WAYPOINT_KEYBINDS.toggle_ui = saved.toggle_ui
			else
				WAYPOINT_KEYBINDS.toggle_ui = 0  -- Default to None if invalid
			end
		end
		if saved.toggle_indicators ~= nil then
			if IsValidKeycode(saved.toggle_indicators) then
				WAYPOINT_KEYBINDS.toggle_indicators = saved.toggle_indicators
			else
				WAYPOINT_KEYBINDS.toggle_indicators = 0  -- Default to None if invalid
			end
		end
		-- Save corrected keybinds if any were invalid
		SaveKeybinds()
	else
		SaveKeybinds()
	end
end)

-- Load localization
modimport("stringlocalization_" .. LOC .. ".lua")
STRINGS = GLOBAL.STRINGS
STRINGS.WAYPOINT = WAYPOINT

-----v MAIN v-----
local function IsScreenBusy()
	local player = ThePlayer()
	if not player or type(player) ~= 'table' then
		return true
	end
	
	local hud = player.HUD
	if not hud or type(hud) ~= 'table' then
		return true
	end
	
	local activeScreen = GLOBAL.TheFrontEnd:GetActiveScreen()
	if not activeScreen then
		return true
	end
	
	local screenName = activeScreen.name
	return not (type(screenName) == 'string' and screenName == 'HUD')
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

-- The Controls widget that currently owns the waypoint UI.
-- The HUD (and therefore Controls) is rebuilt in the same Lua session when the
-- player entity changes (e.g. Celestial Portal character swap), so hotkeys must
-- always act on the latest instance rather than the one they were created with.
local activeControls = nil
local hotkeysRegistered = false

local function GetActiveWaypoint()
	local controls = activeControls
	if controls == nil or controls.waypoint == nil then
		return nil
	end
	if controls.inst == nil or not controls.inst:IsValid() then
		return nil
	end
	return controls.waypoint
end

local function ToggleWaypointUI(waypoint)
	if waypoint:IsVisible() then
		waypoint:Hide()
	else
		waypoint:Show()
	end
end

local function GetHudIconTooltip()
	local tooltip = STRINGS.WAYPOINT.UI.HUD.TOOLTIP
	local keybinds = WAYPOINT_KEYBINDS or {}
	if keybinds.toggle_ui and keybinds.toggle_ui ~= 0 then
		tooltip = tooltip .. "\n(" .. string.upper(string.char(keybinds.toggle_ui)) .. ")"
	end
	return tooltip
end

local function UpdateHudIconTooltip()
	local controls = activeControls
	if controls ~= nil and controls.waypoint_icon ~= nil then
		controls.waypoint_icon:SetTooltip(GetHudIconTooltip())
	end
end

local function CanProcessWaypointHotkey(waypoint)
	if IsScreenBusy() then
		return false
	end

	-- Suppress hotkeys while any waypoint modal dialog is open
	if waypoint.dialogEdit ~= nil or
		waypoint.dialogMp ~= nil or
		waypoint.dialogKeybinds ~= nil or
		waypoint.dialogConfig ~= nil or
		waypoint.dialogIndicatorArea ~= nil then
		return false
	end

	-- Also covers text fields inside the HUD (e.g. crafting search): while one is
	-- being edited, PlayerHud:HasInputFocus() is true and the controller is disabled.
	local player = ThePlayer()
	if not (player and player.components and player.components.playercontroller
		and player.components.playercontroller:IsEnabled()) then
		return false
	end

	return true
end

local function HandleWaypointKeyDown(keycode)
	local waypoint = GetActiveWaypoint()
	if waypoint == nil or not CanProcessWaypointHotkey(waypoint) then
		return
	end

	local keybinds = WAYPOINT_KEYBINDS or {}

	-- if shift is down, toggle marker visibility (for UI key)
	if keybinds.toggle_ui and keybinds.toggle_ui == keycode then
		if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then
			waypoint:ToggleMarkerMode()
		else
			ToggleWaypointUI(waypoint)
		end
	end

	-- Dedicated indicator toggle key
	if keybinds.toggle_indicators and keybinds.toggle_indicators == keycode then
		waypoint:ToggleMarkerMode()
	end
end

local function RegisterHotkeys()
	if hotkeysRegistered then
		return
	end
	hotkeysRegistered = true
	-- Keybinds are restricted to letters (raw keycodes a-z = 97-122), so only those
	-- need handlers. Registered once per session; the handler looks up the active UI.
	for code = string.byte("a"), string.byte("z") do
		GLOBAL.TheInput:AddKeyDownHandler(code, function()
			HandleWaypointKeyDown(code)
		end)
	end
end

-----v CONTROLLER v-----
-- With a controller, the waypoint window is opened from:
--  * DST: the social menu / command wheel (Back/View) - "Waypoints" and
--    "Waypoint indicators" items, see the command wheel section below.
--  * The scoreboard (DST: Player List in the command wheel; DS: the pause screen):
--      RT  open the waypoint window
--      LT  toggle waypoint indicators
-- The window is then fully navigable, see screens/waypointcontrollerscreen.lua.
-- Why not a plain button: during play every controller button already does
-- something. For the scoreboard:
--  * TheInput control handlers only receive controls the active screen did NOT
--    consume (Input:OnControl checks TheFrontEnd:OnControl first), so anything the
--    scoreboard uses (B, X, Y, LB/RB list paging, d-pad, A) never reaches us.
--  * While the scoreboard is open the HUD is not the active screen, so LT/RT don't
--    open crafting/inventory and the player controller is disabled.
--  * During normal play LT/RT are consumed by the HUD and our handler is skipped.
local controllerRegistered = false

local function IsControllerContextScreen()
	local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
	local name = screen and screen.name
	if type(name) ~= "string" then
		return false
	end
	if DST then
		return name == "PlayerStatusScreen"
	end
	return name == "PauseScreen"
end

local function CanProcessControllerAction()
	if not ENABLE_CONTROLLER_SUPPORT then
		return nil
	end
	if not GLOBAL.TheInput:ControllerAttached() then
		return nil -- keyboard users have their own keybinds
	end
	if not IsControllerContextScreen() then
		return nil
	end
	local waypoint = GetActiveWaypoint()
	if waypoint == nil then
		return nil
	end
	-- Don't act while one of our own dialogs is open
	if waypoint.dialogEdit ~= nil or waypoint.dialogMp ~= nil or
		waypoint.dialogKeybinds ~= nil or waypoint.dialogConfig ~= nil or
		waypoint.dialogIndicatorArea ~= nil then
		return nil
	end
	return waypoint
end

local function PlayControllerFeedback()
	GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
end

local function OnControllerToggleIndicators(down)
	if not down then return end
	local waypoint = CanProcessControllerAction()
	if waypoint == nil then return end
	waypoint:ToggleMarkerMode()
	PlayControllerFeedback()
end

-- Close the scoreboard / pause screen we were opened from
local function CloseContextScreen()
	local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
	if screen == nil or not IsControllerContextScreen() then
		return
	end
	if DST and screen.Close ~= nil then
		screen:Close()
	elseif not DST and screen.unpause ~= nil then
		screen:unpause()
	else
		GLOBAL.TheFrontEnd:PopScreen(screen)
		if not DST then
			GLOBAL.SetPause(false)
		end
	end
end

local function OnControllerOpenWindow(down)
	if not down then return end
	local waypoint = CanProcessControllerAction()
	if waypoint == nil then return end
	CloseContextScreen()
	waypoint:OpenWithController()
end

local function RegisterControllerControls()
	if controllerRegistered or not ENABLE_CONTROLLER_SUPPORT then
		return
	end
	controllerRegistered = true
	GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_OPEN_CRAFTING, OnControllerToggleIndicators) -- left trigger
	GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_OPEN_INVENTORY, OnControllerOpenWindow)      -- right trigger
end

-- Show the waypoint controls in the scoreboard's controller help bar
if DST and ENABLE_CONTROLLER_SUPPORT then
	AddClassPostConstruct("screens/playerstatusscreen", function(self)
		local OldGetHelpText = self.GetHelpText
		self.GetHelpText = function(screen, ...)
			local text = OldGetHelpText and OldGetHelpText(screen, ...) or ""
			if GetActiveWaypoint() == nil then
				return text
			end
			local input = GLOBAL.TheInput
			local controller_id = input:GetControllerID()
			local strs = STRINGS.WAYPOINT.UI.CONTROLLER
			local extra =
				input:GetLocalizedControl(controller_id, GLOBAL.CONTROL_OPEN_INVENTORY) .. " " .. strs.OPEN_WINDOW .. "  " ..
				input:GetLocalizedControl(controller_id, GLOBAL.CONTROL_OPEN_CRAFTING) .. " " .. strs.TOGGLE_INDICATORS
			if text ~= "" then
				return text .. "  " .. extra
			end
			return extra
		end
	end)
end

-- Social menu / command wheel (DST controller: the Back/View button).
-- Since the command wheel replaced the hold-to-show scoreboard on controllers,
-- this is the main way in: two extra wheel items open the waypoint window and
-- toggle the indicators. The wheel calls `execute`, then closes itself.
local function HasOpenWaypointDialog(waypoint)
	return waypoint.dialogEdit ~= nil or waypoint.dialogMp ~= nil or
		waypoint.dialogKeybinds ~= nil or waypoint.dialogConfig ~= nil or
		waypoint.dialogIndicatorArea ~= nil
end

local function OnWheelOpenWindow()
	local waypoint = GetActiveWaypoint()
	if waypoint == nil or HasOpenWaypointDialog(waypoint) then
		return
	end
	if GLOBAL.TheInput:ControllerAttached() then
		waypoint:OpenWithController()
	else
		ToggleWaypointUI(waypoint)
	end
end

local function OnWheelToggleIndicators()
	local waypoint = GetActiveWaypoint()
	if waypoint == nil then
		return
	end
	waypoint:ToggleMarkerMode()
	PlayControllerFeedback()
end

local function AddWaypointWheelItems(dataset)
	local strs = STRINGS.WAYPOINT.UI.CONTROLLER
	local items = {}
	for i, v in ipairs(dataset) do
		items[i] = v
	end
	table.insert(items, {
		label = strs.OPEN_WINDOW,
		execute = OnWheelOpenWindow,
		atlas = "images/icon.xml", normal = "icon.tex",
		widget_scale = .8,
	})
	table.insert(items, {
		label = strs.TOGGLE_INDICATORS,
		execute = OnWheelToggleIndicators,
		atlas = "images/nuiwp.xml", normal = "marker.tex",
		widget_scale = 1.4,
	})
	return items
end

if DST and ENABLE_CONTROLLER_SUPPORT then
	AddClassPostConstruct("widgets/controls", function(self)
		local wheel = self.commandwheel
		if wheel == nil or wheel.SetItems == nil or self.BuildCommandWheel == nil then
			print("[waypoint] command wheel not found, social menu items not added")
			return
		end
		local OldSetItems = wheel.SetItems
		wheel.SetItems = function(w, dataset, radius, focus_radius, dataset_name, ...)
			if (dataset_name == nil or dataset_name == "root") and type(dataset) == "table" then
				dataset = AddWaypointWheelItems(dataset)
			end
			return OldSetItems(w, dataset, radius, focus_radius, dataset_name, ...)
		end
		-- The constructor already built the wheel; build it again with our items
		local ok, err = GLOBAL.pcall(self.BuildCommandWheel, self)
		if not ok then
			print("[waypoint] failed to rebuild command wheel: " .. tostring(err))
		end
	end)
end

-----v SETTINGS / HUD BUTTON v-----
local function PositionHudButton(controls)
	if controls.waypoint_icon == nil then return end
	local sw, sh = GetScaledScreen(controls)
	local offX, offY = controls.waypoint_icon:GetSize()
	controls.waypoint_icon:SetPosition(sw/2 - offX/2, -sh + offY*1.2, 0)
end

local function CreateHudButton(controls)
	local ImageButton = CompatibilityImageButton()
	controls.waypoint_icon = controls.top_root:AddChild(
		ImageButton("images/icon.xml","icon.tex","icon.tex","icon.tex")
	)
	controls.waypoint_icon:SetTooltip(GetHudIconTooltip())
	controls.waypoint_icon:SetNormalScale(.7)
	controls.waypoint_icon:SetFocusScale(.8)
	controls.waypoint_icon:SetOnClick(function()
		if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_SHIFT) then
			controls.waypoint:ToggleMarkerMode()
		else
			ToggleWaypointUI(controls.waypoint)
		end
	end)
	PositionHudButton(controls)
end

-- Shown when the setting is on and no controller is attached (controllers can't click it)
local function UpdateHudButton(controls)
	local wanted = WAYPOINT_SETTINGS.show_hud_button and not GLOBAL.TheInput:ControllerAttached()
	if wanted then
		if controls.waypoint_icon == nil then
			CreateHudButton(controls)
		end
		controls.waypoint_icon:Show()
	elseif controls.waypoint_icon ~= nil then
		controls.waypoint_icon:Hide()
	end
end

local RebuildWaypointUI -- defined below (needs AddMod's helpers)

local function ApplySetting(controls, key)
	local waypoint = controls.waypoint
	if key == "window_width" or key == "window_height" then
		RebuildWaypointUI(controls)
	elseif key == "show_hud_button" then
		UpdateHudButton(controls)
	elseif key == "map_icons" then
		waypoint:SetMapIconMode(WAYPOINT_SETTINGS.map_icons)
	elseif key == "sort" then
		waypoint:SetSortMode(WAYPOINT_SETTINGS.sort)
	elseif key == "show_coordinates" then
		waypoint:SetShowCoordinates(WAYPOINT_SETTINGS.show_coordinates)
	elseif key == "click_to_travel" then
		waypoint:SetClickToTravel(WAYPOINT_SETTINGS.click_to_travel)
	elseif key == "indicator_shape" or key == "indicator_area_size" then
		-- Indicators read this every frame, so the change is immediate
		IndicatorArea:Set(WAYPOINT_SETTINGS.indicator_shape, WAYPOINT_SETTINGS.indicator_area_size)
	elseif key == "indicator_names" then
		IndicatorArea.namesOnHover = WAYPOINT_SETTINGS.indicator_names == "hover"
	end
end

-- Builds the waypoint window (+ its indicator layer) and the accessors the
-- dialogs use. Called on HUD creation and again when the window size changes.
local function CreateWaypointUI(controls)
	local MainWp = require "mainwp"
	local NIndicatorManager = require "widgets/nindicatormanager"

	controls.waypoint = controls.top_root:AddChild(
		MainWp(
			WAYPOINT_SETTINGS.window_width,
			WAYPOINT_SETTINGS.window_height,
			SKIN,
			WAYPOINT_SETTINGS.show_coordinates,
			not WAYPOINT_SETTINGS.click_to_travel,
			COLOUR_VARIETY
		)
	)
	controls.waypoint:SetConfiguration(ALWAYS_SHOW_MP)
	controls.waypoint:SetMapIconMode(WAYPOINT_SETTINGS.map_icons)
	controls.waypoint:SetSortMode(WAYPOINT_SETTINGS.sort)
	controls.waypoint.im = controls.top_root:AddChild(NIndicatorManager())
	controls.waypoint.im:MoveToBack()
	controls.waypoint:Hide(true)
	if controls.waypointHudScale ~= nil then
		controls.waypoint:SetScale(controls.waypointHudScale)
	end

	-- Expose keybind accessors to the MainWp instance so the dialog can edit them
	controls.waypoint.getKeybinds = function()
		return {
			toggle_ui = WAYPOINT_KEYBINDS.toggle_ui,
			toggle_indicators = WAYPOINT_KEYBINDS.toggle_indicators,
		}
	end
	controls.waypoint.setKeybinds = function(newbinds)
		if type(newbinds) ~= "table" then return end
		if newbinds.toggle_ui ~= nil then
			WAYPOINT_KEYBINDS.toggle_ui = newbinds.toggle_ui
		end
		if newbinds.toggle_indicators ~= nil then
			WAYPOINT_KEYBINDS.toggle_indicators = newbinds.toggle_indicators
		end
		SaveKeybinds()
		UpdateHudIconTooltip()
	end

	-- Expose in-game settings to the Configurations dialog
	controls.waypoint.getSettings = function()
		local copy = {}
		for k, v in pairs(WAYPOINT_SETTINGS) do copy[k] = v end
		return copy
	end
	controls.waypoint.setSetting = function(key, value)
		local sanitized = SanitizeSetting(key, value)
		if sanitized == nil or sanitized == WAYPOINT_SETTINGS[key] then return end
		WAYPOINT_SETTINGS[key] = sanitized
		SaveSettings()
		ApplySetting(controls, key)
	end
	controls.waypoint.getWindowSizeRange = function()
		return WINDOW_SIZE_MIN, WINDOW_SIZE_MAX, WINDOW_SIZE_STEP
	end
	-- "Reset to default": every setting in the Configurations dialog, keybinds included
	controls.waypoint.resetSettings = function()
		local sizeChanged = WAYPOINT_SETTINGS.window_width ~= DEFAULT_WAYPOINT_SETTINGS.window_width
			or WAYPOINT_SETTINGS.window_height ~= DEFAULT_WAYPOINT_SETTINGS.window_height
		for k, v in pairs(DEFAULT_WAYPOINT_SETTINGS) do
			WAYPOINT_SETTINGS[k] = v
		end
		SaveSettings()
		WAYPOINT_KEYBINDS.toggle_ui = DEFAULT_KEYBINDS.toggle_ui
		WAYPOINT_KEYBINDS.toggle_indicators = DEFAULT_KEYBINDS.toggle_indicators
		SaveKeybinds()
		UpdateHudIconTooltip()
		for k in pairs(DEFAULT_WAYPOINT_SETTINGS) do
			if k ~= "window_width" and k ~= "window_height" then
				ApplySetting(controls, k)
			end
		end
		if sizeChanged then
			RebuildWaypointUI(controls)
		end
	end
end

-- New window size: rebuild the window. Deferred a frame because this runs from
-- a button inside the window being replaced. Keeps indicators on/off, and if
-- the window was open, reopens it with Configurations (and controller mode).
RebuildWaypointUI = function(controls)
	local old = controls.waypoint
	if old == nil or old.rebuildPending then
		return
	end
	old.rebuildPending = true
	local wasShown = old.shown
	local withController = old.controllerScreen ~= nil
	-- Keep the controller cursor on the same Configurations item
	local focusId = nil
	if withController and old.controllerScreen.CurrentNode ~= nil then
		local node = old.controllerScreen:CurrentNode()
		focusId = node ~= nil and node.id or nil
	end
	controls.inst:DoTaskInTime(0, function()
		if controls.waypoint ~= old then
			return
		end
		if old.CloseControllerScreen ~= nil then
			old:CloseControllerScreen() -- also closes its dialogs
		end
		local markerMode = old.markerMode
		old:CleanupWorldObjects()
		if old.im ~= nil then
			old.im:Kill()
		end
		old:Kill()

		CreateWaypointUI(controls)
		local waypoint = controls.waypoint
		if markerMode then
			waypoint:ToggleMarkerMode()
		end
		if wasShown then
			waypoint:Show(true)
			waypoint:OpenConfigDialog()
			if withController then
				waypoint:OpenWithController()
				if focusId ~= nil and waypoint.controllerScreen ~= nil and waypoint.dialogConfig ~= nil then
					waypoint.controllerScreen:FocusId(focusId, waypoint.dialogConfig)
					waypoint.controllerScreen:Refresh()
				end
			end
		end
	end)
end

-- Indicators in a world with nothing saved yet. The modinfo option
-- SHOW_WAYPOINT_INDICATORS was removed; its old value is used if the game still reports it.
local function DefaultIndicatorsOn()
	local old = OldModinfoValue("SHOW_WAYPOINT_INDICATORS")
	if old == nil then
		return true
	end
	return NormalizeBoolean(ExtractConfigData(old), true)
end

-- Post Construct and Key Handlers
local function AddMod(controls)
	controls.inst:DoTaskInTime(0, function()
		-- If the HUD was rebuilt, clean up world entities left by the previous UI
		if activeControls ~= nil and activeControls ~= controls and activeControls.waypoint ~= nil then
			activeControls.waypoint:CleanupWorldObjects()
		end
		activeControls = controls

		CreateWaypointUI(controls)

		-- Continuous update to player's position
		local base_OnUpdate = controls.OnUpdate
		controls.OnUpdate = function(self, dt)
			base_OnUpdate(self, dt)
			if controls.waypoint ~= nil and controls.waypoint:IsVisible() then
				local p = GLOBAL.Point(ThePlayer().Transform:GetWorldPosition())
				controls.waypoint:OnUpdate_PlayerPosition(p)
			end
		end

		RegisterHotkeys()
		RegisterControllerControls()

		-- HUD Icon (setting: show_hud_button)
		UpdateHudButton(controls)

		-- Update hud size and position on event (best to update through event than overriding PlayerProfile.GetHUDSize)
		if DST then
			ThePlayer().HUD.inst:ListenForEvent("refreshhudsize", function(hud, scale)
				controls.waypointHudScale = scale
				if controls.waypoint then
					controls.waypoint:SetScale(scale)
				end
				PositionHudButton(controls)
			end)
			
			ThePlayer().HUD.inst:PushEvent("refreshhudsize", GLOBAL.TheFrontEnd:GetHUDScale())
		end


		-- Indicators on/off is remembered per world (on in a world you haven't
		-- joined before, unless the old "Indicators on at start" option says off)
		if controls.waypoint and controls.waypoint:GetSavedIndicatorsOn(DefaultIndicatorsOn()) then
			controls.waypoint:ToggleMarkerMode()
		end

	end)
end

-- Map icon template manager (whether icons show is decided per waypoint by the
-- map_icons setting, each time the map opens)
do
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

AddClassPostConstruct("widgets/controls", AddMod)
AddClassPostConstruct("widgets/mapwidget", require "widgets/nmapwidget")
-- Controller: travel to the waypoint under the map crosshair (Y)
AddClassPostConstruct("screens/mapscreen", require "widgets/nmapscreen")
