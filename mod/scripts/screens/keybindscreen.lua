--[[
KeybindScreen
Simple modal screen that captures a single key press.
]]

local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local NPanel = require "widgets/npanel"
local NBox = require "util/nbox"
local Styler = require "styler"

local Compatibility = require "util/compatibility"
local Text = Compatibility:Text()
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()

local KeybindScreen = Class(Screen, function(self, oncaptured, oncancel, skin)
	Screen._ctor(self, "WaypointKeybindScreen")

	self.oncaptured = oncaptured
	self.oncancel = oncancel

	self.root = self:AddChild(Widget("KeybindRoot"))

	-- Add dark overlay background to dim the screen
	self.overlay = self.root:AddChild(Image("images/ui.xml", "black.tex"))
	self.overlay:SetVAnchor(ANCHOR_MIDDLE)
	self.overlay:SetHAnchor(ANCHOR_MIDDLE)
	local screenWidth, screenHeight = TheSim:GetScreenSize()
	self.overlay:SetSize(screenWidth, screenHeight)
	self.overlay:SetTint(0, 0, 0, 0.5)
	self.overlay:MoveToBack()

	self.panel = self.root:AddChild(NPanel("KeybindDialog"))
	self.panel:SetVAnchor(ANCHOR_MIDDLE)
	self.panel:SetHAnchor(ANCHOR_MIDDLE)
	self.panel:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.panel:SetPosition(0, 20)
	self.panel:SetSize(500, 140)
	self.panel:AddClass("Frame")

	local box = NBox(self.panel:GetSize())
	local maxRows = 4

	self.title = self.panel:AddChild(Text(TALKINGFONT, 26))
	self.title:SetPosition(0, box:GridY(1, maxRows))
	self.title:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.CAPTURE_TITLE)

	self.label1 = self.panel:AddChild(Text(TALKINGFONT, 20))
	self.label1:SetPosition(0, box:GridY(2, maxRows))
	self.label1:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.INSTRUCTIONS_LINE1)

	self.label2 = self.panel:AddChild(Text(TALKINGFONT, 20))
	self.label2:SetPosition(0, box:GridY(3, maxRows))
	self.label2:SetString(STRINGS.WAYPOINT.UI.DIALOG.KEYBINDS.INSTRUCTIONS_LINE2)

	self.btnCancel = self.panel:AddChild(ImageButton())
	self.btnCancel:SetPosition(0, -box:H() / 2 - 20 / 2)
	self.btnCancel:SetScale(.7, .7, .7)
	self.btnCancel:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.CANCEL)
	self.btnCancel:SetOnClick(function()
		if self.oncancel ~= nil then
			self.oncancel()
		end
		TheFrontEnd:PopScreen(self)
	end)

	Styler(skin or 1):ApplyStyle(self.panel)
end)

function KeybindScreen:OnRawKey(key, down)
	if not down then
		return false
	end

	-- Backspace clears binding (keycode 0)
	if key == KEY_BACKSPACE then
		if self.oncaptured ~= nil then
			self.oncaptured(0)
		end
		TheFrontEnd:PopScreen(self)
		return true
	end

	-- Ignore ESC to prevent opening game menu
	if key == KEY_ESCAPE then
		return true
	end

	-- Only letters can be bound (raw keycodes a-z). Ignore anything else
	-- (Shift, Tab, digits, F-keys...) and keep waiting instead of clearing the bind.
	if type(key) ~= "number" or key < string.byte("a") or key > string.byte("z") then
		return true
	end

	if self.oncaptured ~= nil then
		self.oncaptured(key)
	end
	TheFrontEnd:PopScreen(self)
	return true
end

-- Controller: B cancels (keys can only be captured from a keyboard)
function KeybindScreen:OnControl(control, down)
	if KeybindScreen._base.OnControl(self, control, down) then
		return true
	end
	if not down and control == CONTROL_CANCEL then
		if self.oncancel ~= nil then
			self.oncancel()
		end
		TheFrontEnd:PopScreen(self)
		return true
	end
	return false
end

return KeybindScreen
