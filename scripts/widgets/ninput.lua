--[[
NInput
By Nc5xb3
Custom input field that works more like one in-game
]]

local NInputScreen = require "screens/ninputscreen"
local NPanel = require "widgets/npanel"

local Compatibility = require "util/compatibility"
local TextButton = Compatibility:TextButton()

local NInput = Class(NPanel, function(self, name)
	NPanel._ctor(self, name)
	self.class = {"NInput"}
	self.callback = nil

	self.font = Compatibility:NewFont()
	self.fontSize = 28
	self.limit = 254

	self.input = self:AddChild(TextButton())
	self.input:SetFont(self.font)
	self.input:SetTextSize(self.fontSize)
	self.input:SetColour(.9,.9,.9,1)
	self.input:SetOverColour(1,1,1,1)
	self.input:SetOnClick(function() self:CreateInputScreen() end)
end)

function NInput:SetFont(font)
	self.font = font
	self.input:SetFont(self.font)
end

function NInput:SetFontSize(fontsize)
	self.fontSize = fontsize
	self.input:SetTextSize(self.fontSize)
end

function NInput:SetPosition(x,y,z)
	NInput._base.SetPosition(self,x,y,z)
end

function NInput:SetSize(w,h)
	NInput._base.SetSize(self,w,h)
	self.input.text:SetRegionSize(w,h)
end

function NInput:SetCallback(callback)
	self.callback = callback
end

function NInput:CreateInputScreen()
	self.inputScreen = self:AddChild(NInputScreen(self))
	self.inputScreen:SetString(self.input:GetText())
	self.inputScreen.input:SetRegionSize(self:GetSize()[1],self:GetSize()[2])
	self.inputScreen.input:SetFont(self.font)
	self.inputScreen.input:SetSize(self.fontSize)
	if self.limit then
		self.inputScreen.input:SetTextLengthLimit(self.limit)
	end
	if self.regionlimit then
		self.inputScreen.input:EnableRegionSizeLimit(self.regionlimit)
	end
	if self.validchars then
		self.inputScreen.input:SetCharacterFilter(self.validchars)
	end
	if self.invalidchars then
		self.inputScreen.input:SetInvalidCharacterFilter(self.invalidchars)
	end
	if Compatibility:IsDST() then
		self.input:SetText("")
	else
		self.input:SetText("...")
	end
	TheFrontEnd:PushScreen(self.inputScreen)
end

function NInput:SetTextLengthLimit(limit)
    self.limit = limit
end

function NInput:EnableRegionSizeLimit(enable)
    self.regionlimit = enable
end

function NInput:SetCharacterFilter(validchars)
    self.validchars = validchars
end

function NInput:SetInvalidCharacterFilter(invalidchars)
    self.invalidchars = invalidchars
end


return NInput