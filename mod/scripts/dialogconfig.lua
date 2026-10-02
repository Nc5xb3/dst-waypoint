--[[
DialogConfig
In-game settings: keybinds, HUD button, map icons, coordinates, click-to-travel.
Settings apply immediately and are saved per client (see modmain WAYPOINT_SETTINGS).
Debug information is behind a small "Debug info" button.
]]

local NPanel = require "widgets/npanel"
local Styler = require "styler"
local NBox = require "util/nbox"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Text = Compatibility:Text()

local LABEL_FONT_SIZE = 24
local DESC_FONT_SIZE = 17
local DESC_COLOUR = {.85, .8, .65, 1} -- muted gold, reads as secondary text
local BUTTON_SCALE = .55
local MAP_ICON_MODES = { "all", "visible", "off" }
local DialogIndicatorArea = require "dialogindicatorarea"

local DialogConfig = Class(NPanel, function(self, w, h, skin, mainwp)
	NPanel._ctor(self, "DialogConfig")
	self.skin = skin or 1
	self.mainwp = mainwp

	self:SetCancelCallback(nil)
	self.getKeybinds = nil
	self.setKeybinds = nil

	self:InitialiseComponents(w or 520, h or 500)
	Styler(skin or 1):ApplyStyle(self)
	self:RefreshValues()
end)

local function Strings()
	return STRINGS.WAYPOINT.UI.DIALOG.CONFIG
end

-- One setting row:
--   Title                         [button]
--   short description of the current value
-- Returns label, description, button
function DialogConfig:AddSettingRow(box, row, maxRows, labelText, onclick)
	local rowY = box:GridY(row, maxRows)
	local buttonX = box:W() / 4 + 25
	local left = -box:W() / 2 + 25
	local textWidth = (buttonX - 95) - left -- stop well before the button

	local label = self:AddChild(Text(TALKINGFONT, LABEL_FONT_SIZE))
	label:SetRegionSize(textWidth, 30)
	label:SetHAlign(ANCHOR_LEFT)
	label:SetPosition(left + textWidth / 2, rowY + 11)
	label:SetString(labelText)

	local desc = self:AddChild(Text(TALKINGFONT, DESC_FONT_SIZE))
	desc:SetRegionSize(textWidth, 36)
	desc:SetHAlign(ANCHOR_LEFT)
	desc:SetVAlign(ANCHOR_TOP)
	desc:EnableWordWrap(true) -- longer translations wrap onto a second line
	desc:SetColour(DESC_COLOUR[1], DESC_COLOUR[2], DESC_COLOUR[3], DESC_COLOUR[4])
	desc:SetPosition(left + textWidth / 2, rowY - 19)

	local button = self:AddChild(ImageButton())
	button:SetPosition(buttonX, rowY)
	button:SetScale(BUTTON_SCALE, BUTTON_SCALE, BUTTON_SCALE)
	button:SetOnClick(onclick)
	return label, desc, button
end

function DialogConfig:InitialiseComponents(w, h)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self:SetPosition(0, 20)
	self:SetSize(w, h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())
	local maxRows = 8
	local strs = Strings()

	-- Title
	self.lblTitle = self:AddChild(Text(TALKINGFONT, 28))
	self.lblTitle:SetPosition(0, box:GridY(1, maxRows), 0)
	self.lblTitle:SetString(strs.TITLE)

	-- Keybinds
	self.lblKeybinds, self.descKeybinds, self.btnKeybinds = self:AddSettingRow(box, 2, maxRows,
		STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.TITLE,
		function()
			if self.mainwp then
				self.mainwp:OpenKeybindDialog()
			end
		end)
	self.btnKeybinds:SetText(STRINGS.WAYPOINT.UI.BUTTON.EDIT)

	-- HUD button
	self.lblHudButton, self.descHudButton, self.btnHudButton = self:AddSettingRow(box, 3, maxRows,
		strs.HUD_BUTTON,
		function() self:ToggleBool("show_hud_button") end)

	-- Map icons: All / Visible only / Off
	self.lblMapIcons, self.descMapIcons, self.btnMapIcons = self:AddSettingRow(box, 4, maxRows,
		strs.MAP_ICONS,
		function() self:CycleMapIcons() end)

	-- Coordinates
	self.lblCoordinates, self.descCoordinates, self.btnCoordinates = self:AddSettingRow(box, 5, maxRows,
		strs.COORDINATES,
		function() self:ToggleBool("show_coordinates") end)

	-- Click flag to travel
	self.lblTravel, self.descTravel, self.btnTravel = self:AddSettingRow(box, 6, maxRows,
		strs.CLICK_TO_TRAVEL,
		function() self:ToggleBool("click_to_travel") end)

	-- Indicator area: opens its own dialog with a live on-screen preview
	self.lblIndicatorArea, self.descIndicatorArea, self.btnIndicatorArea = self:AddSettingRow(box, 7, maxRows,
		strs.INDICATOR_AREA,
		function()
			if self.mainwp then
				self.mainwp:OpenIndicatorAreaDialog()
			end
		end)
	self.btnIndicatorArea:SetText(STRINGS.WAYPOINT.UI.BUTTON.EDIT)

	-- Debug info (small, out of the way)
	self.btnDebug = self:AddChild(ImageButton())
	self.btnDebug:SetPosition(0, box:GridY(8, maxRows))
	self.btnDebug:SetScale(.4, .4, .4)
	self.btnDebug:SetText(strs.DEBUG_BUTTON)
	self.btnDebug:SetOnClick(function() self:ShowDebugInfo() end)

	-- Close button
	self.btnClose = self:AddChild(ImageButton())
	self.btnClose:SetPosition(0, -box:H() / 2 - 20 / 2)
	self.btnClose:SetScale(.7, .7, .7)
	self.btnClose:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.CLOSE)
	self.btnClose:SetOnClick(function()
		if self.cancel_callback ~= nil then
			self.cancel_callback()
		end
	end)
end

function DialogConfig:GetSettings()
	if self.mainwp and self.mainwp.getSettings then
		return self.mainwp.getSettings()
	end
	return {}
end

function DialogConfig:SetSetting(key, value)
	if self.mainwp and self.mainwp.setSetting then
		self.mainwp.setSetting(key, value)
	end
	self:RefreshValues()
end

function DialogConfig:ToggleBool(key)
	local settings = self:GetSettings()
	self:SetSetting(key, not settings[key])
end

function DialogConfig:CycleMapIcons()
	local current = self:GetSettings().map_icons or "all"
	local nextMode = MAP_ICON_MODES[1]
	for i, mode in ipairs(MAP_ICON_MODES) do
		if mode == current then
			nextMode = MAP_ICON_MODES[i % #MAP_ICON_MODES + 1]
			break
		end
	end
	self:SetSetting("map_icons", nextMode)
end

local function KeyName(keycode)
	if type(keycode) == "number" and keycode >= string.byte("a") and keycode <= string.byte("z") then
		return string.upper(string.char(keycode))
	end
	return STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.NONE
end

-- Button text = current value; description = what that value does
function DialogConfig:RefreshValues()
	local strs = Strings()
	local settings = self:GetSettings()
	local function onoff(v) return v and strs.ON or strs.OFF end

	-- Keybinds: show the current keys
	local keybinds = (self.mainwp and self.mainwp.getKeybinds and self.mainwp.getKeybinds()) or {}
	self.descKeybinds:SetString(string.format(strs.KEYBINDS_DESC,
		KeyName(keybinds.toggle_ui), KeyName(keybinds.toggle_indicators)))

	self.btnHudButton:SetText(onoff(settings.show_hud_button))
	self.descHudButton:SetString(settings.show_hud_button and strs.HUD_BUTTON_DESC_ON or strs.HUD_BUTTON_DESC_OFF)

	self.btnCoordinates:SetText(onoff(settings.show_coordinates))
	self.descCoordinates:SetString(settings.show_coordinates and strs.COORDINATES_DESC_ON or strs.COORDINATES_DESC_OFF)

	self.btnTravel:SetText(onoff(settings.click_to_travel))
	self.descTravel:SetString(settings.click_to_travel and strs.CLICK_TO_TRAVEL_DESC_ON or strs.CLICK_TO_TRAVEL_DESC_OFF)

	self.descIndicatorArea:SetString(string.format(strs.INDICATOR_AREA_DESC,
		DialogIndicatorArea.ShapeName(settings.indicator_shape or "rectangle"),
		tostring(settings.indicator_area_size or 50)))

	local mode = settings.map_icons or "all"
	if mode == "visible" then
		self.btnMapIcons:SetText(strs.MAP_ICONS_VISIBLE)
		self.descMapIcons:SetString(strs.MAP_ICONS_DESC_VISIBLE)
	elseif mode == "off" then
		self.btnMapIcons:SetText(strs.MAP_ICONS_OFF)
		self.descMapIcons:SetString(strs.MAP_ICONS_DESC_OFF)
	else
		self.btnMapIcons:SetText(strs.MAP_ICONS_ALL)
		self.descMapIcons:SetString(strs.MAP_ICONS_DESC_ALL)
	end
end

function DialogConfig:ShowDebugInfo()
	local strs = Strings()
	local uwid = "N/A"
	local count = 0
	if self.mainwp then
		if self.mainwp.uwid then
			uwid = tostring(self.mainwp.uwid)
		end
		if self.mainwp.waypoints then
			-- Compact waypoints first to get an accurate count
			self.mainwp:CompactWaypoints()
			count = #self.mainwp.waypoints
		end
	end

	local PopupDialogScreen = Compatibility:PopupDialogScreen()
	local popup
	popup = PopupDialogScreen(
		strs.DEBUG_TITLE,
		strs.UWID_LABEL .. " " .. uwid .. "\n" .. strs.WAYPOINT_COUNT_LABEL .. " " .. tostring(count),
		{
			{text = STRINGS.WAYPOINT.UI.DIALOG.OPTION.CLOSE, cb = function()
				TheFrontEnd:PopScreen(popup)
			end},
		}
	)
	TheFrontEnd:PushScreen(popup)
end

function DialogConfig:SetCancelCallback(callback)
	self.cancel_callback = callback
end

function DialogConfig:SetKeybindAccessors(getter, setter)
	self.getKeybinds = getter
	self.setKeybinds = setter
end

function DialogConfig:Kill()
	if self.mainwp and self.mainwp.dialogConfig == self then
		self.mainwp.dialogConfig = nil
	end
	NPanel.Kill(self)
end

-- Controller navigation (screens/waypointcontrollerscreen.lua)
function DialogConfig:GetControllerRows(screen)
	return {
		{ { id = "keybinds", widget = self.btnKeybinds } },
		{ { id = "hud", widget = self.btnHudButton } },
		{ { id = "map", widget = self.btnMapIcons } },
		{ { id = "coords", widget = self.btnCoordinates } },
		{ { id = "travel", widget = self.btnTravel } },
		{ { id = "area", widget = self.btnIndicatorArea } },
		{ { id = "debug", widget = self.btnDebug } },
		{ { id = "close", widget = self.btnClose } },
	}
end

function DialogConfig:OnControllerCancel()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
end

return DialogConfig
