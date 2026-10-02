--[[
DialogConfig
Configuration dialog with keybinds and debug information
]]

local NPanel = require "widgets/npanel"
local Styler = require "styler"
local NBox = require "util/nbox"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Text = Compatibility:Text()

local DialogConfig = Class(NPanel, function(self, w, h, skin, mainwp)
	NPanel._ctor(self, "DialogConfig")
	self.skin = skin or 1
	self.mainwp = mainwp

	self:SetCancelCallback(nil)
	self.getKeybinds = nil
	self.setKeybinds = nil

	self:InitialiseComponents(w or 450, h or 350)
	Styler(skin or 1):ApplyStyle(self)
end)

function DialogConfig:InitialiseComponents(w, h)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self:SetPosition(0, 20)
	self:SetSize(w, h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())

	local maxCols = 10
	local maxRows = 8

	-- Title
	self.lblTitle = self:AddChild(Text(TALKINGFONT, 28))
	self.lblTitle:SetPosition(0, box:GridY(1, maxRows), 0)
	self.lblTitle:SetString(STRINGS.WAYPOINT.UI.DIALOG.CONFIG.TITLE)

	-- Keybinds button
	self.btnKeybinds = self:AddChild(ImageButton())
	self.btnKeybinds:SetPosition(0, box:GridY(3, maxRows))
	self.btnKeybinds:SetScale(.7, .7, .7)
	self.btnKeybinds:SetText(STRINGS.WAYPOINT.UI.BUTTON.EDIT_KEYBINDS)
	self.btnKeybinds:SetOnClick(function()
		if self.mainwp then
			self.mainwp:OpenKeybindDialog()
		end
	end)

	-- Debug information section
	self.lblDebugTitle = self:AddChild(Text(TALKINGFONT, 22))
	self.lblDebugTitle:SetPosition(0, box:GridY(5, maxRows))
	self.lblDebugTitle:SetString(STRINGS.WAYPOINT.UI.DIALOG.CONFIG.DEBUG_TITLE)

	-- UWID display
	self.lblUwidLabel = self:AddChild(Text(TALKINGFONT, 18))
	self.lblUwidLabel:SetPosition(box:GridX(2, maxCols), box:GridY(6, maxRows))
	self.lblUwidLabel:SetString(STRINGS.WAYPOINT.UI.DIALOG.CONFIG.UWID_LABEL)
	self.lblUwidLabel:SetHAlign(ANCHOR_LEFT)

	self.lblUwid = self:AddChild(Text(NUMBERFONT, 18))
	self.lblUwid:SetPosition(box:GridX(8, maxCols), box:GridY(6, maxRows))
	self.lblUwid:SetHAlign(ANCHOR_LEFT)

	-- Waypoint count display
	self.lblWaypointCountLabel = self:AddChild(Text(TALKINGFONT, 18))
	self.lblWaypointCountLabel:SetPosition(box:GridX(2, maxCols), box:GridY(7, maxRows))
	self.lblWaypointCountLabel:SetString(STRINGS.WAYPOINT.UI.DIALOG.CONFIG.WAYPOINT_COUNT_LABEL)
	self.lblWaypointCountLabel:SetHAlign(ANCHOR_LEFT)

	self.lblWaypointCount = self:AddChild(Text(NUMBERFONT, 18))
	self.lblWaypointCount:SetPosition(box:GridX(8, maxCols), box:GridY(7, maxRows))
	self.lblWaypointCount:SetHAlign(ANCHOR_LEFT)

	-- Update debug info
	self:UpdateDebugInfo()

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

function DialogConfig:UpdateDebugInfo()
	if self.mainwp then
		-- Update UWID
		if self.mainwp.uwid then
			self.lblUwid:SetString(tostring(self.mainwp.uwid))
		else
			self.lblUwid:SetString("N/A")
		end

		-- Update waypoint count
		if self.mainwp.waypoints then
			-- Compact waypoints first to get accurate count
			self.mainwp:CompactWaypoints()
			local count = #self.mainwp.waypoints
			self.lblWaypointCount:SetString(tostring(count))
		else
			self.lblWaypointCount:SetString("0")
		end
	end
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

return DialogConfig

