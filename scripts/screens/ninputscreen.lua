--[[
NInputScreen
By Nc5xb3
Used to lock the player to focus on an input field which will be used by NInput widget
]]

local Screen = require "widgets/screen"
local Widget = require "widgets/widget"

local Compatibility = require "util/compatibility"
local TextEdit = Compatibility:TextEdit()

local NInputScreen = Class(Screen, function(self, bparent)
	Screen._ctor(self, "NInputScreen")
	-- Because apparantly the parent became screenroot >:( instead use bparent; biological parent
	self.bparent = bparent

	TheInput:EnableDebugToggle(false)

	if Compatibility:IsDST() then
		self.input = self.bparent:AddChild(TextEdit(
			self.bparent.font,
			self.bparent.fontSize,"")
		)
	else
		self.input = self:AddChild(TextEdit(
			self.bparent.font,
			self.bparent.fontSize,"")
		)
		self:SetVAnchor(ANCHOR_TOP)
		self:SetHAnchor(ANCHOR_MIDDLE)
		self.input:SetPosition(0,-50,0)
	end

	self.input:SetHAlign(ANCHOR_MIDDLE)
	self.input:SetTextLengthLimit(self.bparent.limit)

	self.input:SetIdleTextColour(.9,.8,.6,1)
	self.input:SetEditTextColour(1,1,1,1)
	self.input:SetEditCursorColour(1,1,1,1)

	self.input:SetPassControlToScreen(CONTROL_CANCEL, true)

	if Compatibility:IsDST() then
		self.input:SetPassControlToScreen(CONTROL_MENU_MISC_2, true)
	end

	self.input:SetForceEdit(true)
	if not Compatibility:IsDST() then
		SetPause(true,"input")
	end

	self.input.OnTextEntered = function() self:OnTextEntered() end

	self:SetString("")
end)

function NInputScreen:SetString(string)
	self.originalstring = string
	self.input:SetString(string)
end

function NInputScreen:OnControl(control, down)
	if not down and
		(control == CONTROL_CANCEL or (Compatibility:IsDST() and control == CONTROL_MENU_MISC_2)) then
		self:OnTextCancelled()
		return true
	end

	if NInputScreen._base.OnControl(self, control, down) then
		return true
	end

	if (self.input and self.input.editing) 
		or (TheInput:ControllerAttached() and self.input.focus 
			and control == CONTROL_ACCEPT) then
		self.input:OnControl(control, down)
	   return true
	end
end

function NInputScreen:OnBecomeInactive()
	NInputScreen._base.OnBecomeInactive(self)
end

function NInputScreen:OnBecomeActive()
	NInputScreen._base.OnBecomeActive(self)
	self.input:SetFocus()
	self.input:SetEditing(true)
	TheFrontEnd:LockFocus(true)
end

function NInputScreen:OnStopForceProcessTextInput()

end

function NInputScreen:OnTextCancelled()
	self.bparent.input:SetText(self.originalstring)
	self:Close()
end

function NInputScreen:OnTextEntered()
	local result = self.input:GetString()
	self.bparent.input:SetText(result)
	if self.bparent.callback ~= nil then
		self.bparent.callback()
	end
	self:Close()
end

function NInputScreen:Close()
	if not Compatibility:IsDST() then
		SetPause(false)
	end
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
	self.input:Kill()
	self.input = nil
end

return NInputScreen