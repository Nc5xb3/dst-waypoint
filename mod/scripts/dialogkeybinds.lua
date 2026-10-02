--[[
DialogKeybinds
By Nc5xb3 (extended)
Dialog to edit waypoint keybinds
]]

local NPanel = require "widgets/npanel"
local Styler = require "styler"
local NBox = require "util/nbox"
local KeybindScreen = require "screens/keybindscreen"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Text = Compatibility:Text()

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

local function KeyCodeToDisplay(keycode)
	if not keycode or keycode == 0 then
		return STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.NONE
	end
	-- Safety check: validate keycode before converting to character
	if not IsValidKeycode(keycode) then
		return STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.NONE
	end
	-- IsValidKeycode ensures keycode is a valid letter (65-90 or 97-122), so string.char is safe
	local ch = string.char(keycode)
	return string.upper(ch)
end

local function DisplayToKeyCode(text)
	if not text or text == "" then
		return 0
	end
	local ch = string.sub(text, 1, 1)
	ch = string.lower(ch)
	local byte = string.byte(ch)
	-- Only allow letters A-Z (a-z)
	if byte >= string.byte("a") and byte <= string.byte("z") then
		return byte
	end
	return nil
end

local DialogKeybinds = Class(NPanel, function(self, w, h, skin)
	NPanel._ctor(self, "DialogKeybinds")

	self:SetSuccessCallback(nil)
	self:SetCancelCallback(nil)
	self.getKeybinds = nil
	self.setKeybinds = nil
	self.currentKeys = { toggle_ui = 0, toggle_indicators = 0 }
	self.skin = skin or 1

	self:InitialiseComponents(w or 420, h or 260)
	Styler(skin or 1):ApplyStyle(self)
end)

function DialogKeybinds:InitialiseComponents(w, h)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self:SetPosition(0, 20)
	self:SetSize(w, h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())

	local maxCols = 10
	local maxRows = 6

	-- Title
	self.lblTitle = self:AddChild(Text(TALKINGFONT, 28))
	self.lblTitle:SetPosition(0, box:GridY(1, maxRows), 0)
	self.lblTitle:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.TITLE)

	-- Instructions
	self.lblInstructions = self:AddChild(Text(TALKINGFONT, 20))
	self.lblInstructions:SetPosition(0, box:GridY(2, maxRows), 0)
	self.lblInstructions:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.INSTRUCTIONS)

	-- Toggle UI visibility
	self.lblToggleUi = self:AddChild(Text(TALKINGFONT, 22))
	self.lblToggleUi:SetPosition(box:GridX(4, maxCols), box:GridY(3, maxRows))
	self.lblToggleUi:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.ACTION_TOGGLE_UI)
	self.lblToggleUi:SetHAlign(ANCHOR_LEFT)

	self.btnToggleUi = self:AddChild(ImageButton())
	self.btnToggleUi:SetPosition(box:GridX(8, maxCols), box:GridY(3, maxRows))
	self.btnToggleUi:SetScale(.7, .7, .7)
	self.btnToggleUi:SetOnClick(function()
		self:StartCapture("toggle_ui")
	end)

	-- Toggle indicators
	self.lblToggleIndicators = self:AddChild(Text(TALKINGFONT, 22))
	self.lblToggleIndicators:SetPosition(box:GridX(4, maxCols), box:GridY(4, maxRows))
	self.lblToggleIndicators:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.ACTION_TOGGLE_INDICATORS)
	self.lblToggleIndicators:SetHAlign(ANCHOR_LEFT)

	self.btnToggleIndicators = self:AddChild(ImageButton())
	self.btnToggleIndicators:SetPosition(box:GridX(8, maxCols), box:GridY(4, maxRows))
	self.btnToggleIndicators:SetScale(.7, .7, .7)
	self.btnToggleIndicators:SetOnClick(function()
		self:StartCapture("toggle_indicators")
	end)

	-- Load current keybinds into inputs
	self:LoadCurrentKeybinds()

	-- Buttons
	self.btnSave = self:AddChild(ImageButton())
	self.btnSave:SetPosition(-box:W() / 4, -box:H() / 2 - 20 / 2)
	self.btnSave:SetScale(.7, .7, .7)
	self.btnSave:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.SAVE)
	self.btnSave:SetOnClick(function()
		self:ApplyKeybinds()
	end)

	self.btnCancel = self:AddChild(ImageButton())
	self.btnCancel:SetPosition(box:W() / 4, -box:H() / 2 - 20 / 2)
	self.btnCancel:SetScale(.7, .7, .7)
	self.btnCancel:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.CANCEL)
	self.btnCancel:SetOnClick(function()
		if self.cancel_callback ~= nil then
			self.cancel_callback()
		end
	end)
end

function DialogKeybinds:LoadCurrentKeybinds()
	if not self.getKeybinds then
		return
	end

	local keybinds = self.getKeybinds() or {}
	self.currentKeys.toggle_ui = keybinds.toggle_ui or 0
	self.currentKeys.toggle_indicators = keybinds.toggle_indicators or 0

	self:RefreshKeyTexts()
end

function DialogKeybinds:ApplyKeybinds()
	if not self.setKeybinds or not self.getKeybinds then
		return
	end

	-- Validate keybinds before saving - default invalid ones to 0 (None)
	local toggle_ui = self.currentKeys.toggle_ui or 0
	if not IsValidKeycode(toggle_ui) then
		toggle_ui = 0
	end

	local toggle_indicators = self.currentKeys.toggle_indicators or 0
	if not IsValidKeycode(toggle_indicators) then
		toggle_indicators = 0
	end

	local newKeybinds = {
		toggle_ui = toggle_ui,
		toggle_indicators = toggle_indicators,
	}

	self.setKeybinds(newKeybinds)

	if self.success_callback ~= nil then
		self.success_callback()
	end
end

function DialogKeybinds:SetSuccessCallback(callback)
	self.success_callback = callback
end

function DialogKeybinds:SetCancelCallback(callback)
	self.cancel_callback = callback
end

function DialogKeybinds:SetKeybindAccessors(getter, setter)
	self.getKeybinds = getter
	self.setKeybinds = setter
	self:LoadCurrentKeybinds()
end

function DialogKeybinds:RefreshKeyTexts()
	if self.btnToggleUi ~= nil then
		self.btnToggleUi:SetText(KeyCodeToDisplay(self.currentKeys.toggle_ui))
	end
	if self.btnToggleIndicators ~= nil then
		self.btnToggleIndicators:SetText(KeyCodeToDisplay(self.currentKeys.toggle_indicators))
	end
end

function DialogKeybinds:StartCapture(which)
	local function oncaptured(keycode)
		-- Validate keycode - default to 0 (None) if invalid
		if not IsValidKeycode(keycode) then
			keycode = 0
		end
		
		-- Check for key conflicts (ignore if keycode is 0/None)
		if keycode ~= 0 then
			if which == "toggle_ui" then
				-- If this key is already bound to indicators, clear it
				if self.currentKeys.toggle_indicators == keycode then
					self.currentKeys.toggle_indicators = 0
				end
				self.currentKeys.toggle_ui = keycode
			elseif which == "toggle_indicators" then
				-- If this key is already bound to UI, clear it
				if self.currentKeys.toggle_ui == keycode then
					self.currentKeys.toggle_ui = 0
				end
				self.currentKeys.toggle_indicators = keycode
			end
		else
			-- Backspace clears the binding
			if which == "toggle_ui" then
				self.currentKeys.toggle_ui = 0
			elseif which == "toggle_indicators" then
				self.currentKeys.toggle_indicators = 0
			end
		end
		self:RefreshKeyTexts()
	end

	local function oncancel()
		-- Do nothing on cancel
	end

	TheFrontEnd:PushScreen(KeybindScreen(oncaptured, oncancel, self.skin))
end

-- Controller navigation (screens/waypointcontrollerscreen.lua). Keybinds are
-- keyboard keys, but the dialog can still be browsed and closed with a controller.
function DialogKeybinds:GetControllerRows(screen)
	return {
		{ { id = "ui", widget = self.btnToggleUi, hint = STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.ACTION_TOGGLE_UI } },
		{ { id = "indicators", widget = self.btnToggleIndicators, hint = STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.ACTION_TOGGLE_INDICATORS } },
		{
			{ id = "save", widget = self.btnSave },
			{ id = "cancel", widget = self.btnCancel },
		},
	}
end

function DialogKeybinds:OnControllerCancel()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
end

return DialogKeybinds
