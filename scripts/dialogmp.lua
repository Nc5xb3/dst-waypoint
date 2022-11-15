--[[
DialogMp
By Nc5xb3
Dialog with regards to movement prediction disabled
]]

local NPanel = require "widgets/npanel"
local Styler = require "styler"
local NBox = require "util/nbox"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Text = Compatibility:Text()

local DialogMp = Class(NPanel, function(self,w,h,skin)
    NPanel._ctor(self, "DialogMp")

    self:SetOkayCallback(nil)

	self:InitialiseComponents(w or 500,h or 250)
	Styler(skin or 1):ApplyStyle(self)
end)

function DialogMp:InitialiseComponents(w,h)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self:SetPosition(0,20)
	self:SetSize(w,h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())

	local maxCols = 10
	local maxRows = 6

	--

	self.lblTitle = self:AddChild(Text(TALKINGFONT,28))
	self.lblTitle:SetPosition(0,box:GridY(1,maxRows))
	self.lblTitle:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.TITLE)

	self.lblMessage1 = self:AddChild(Text(TALKINGFONT,24))
	self.lblMessage1:SetPosition(0,box:GridY(2,maxRows))
	self.lblMessage1:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.MESSAGE1)

	self.lblMessage2 = self:AddChild(Text(TALKINGFONT,24))
	self.lblMessage2:SetPosition(0,box:GridY(3,maxRows))
	self.lblMessage2:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.MESSAGE2)

	self.lblMessage3 = self:AddChild(Text(TALKINGFONT,24))
	self.lblMessage3:SetPosition(0,box:GridY(4,maxRows))
	self.lblMessage3:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.MESSAGE3)

	self.lblMessage4 = self:AddChild(Text(TALKINGFONT,24))
	self.lblMessage4:SetPosition(0,box:GridY(5,maxRows))
	self.lblMessage4:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.MESSAGE4)

	self.lblMessage5 = self:AddChild(Text(TALKINGFONT,24))
	self.lblMessage5:SetPosition(0,box:GridY(6,maxRows))
	self.lblMessage5:SetString(STRINGS.WAYPOINT.UI.DIALOG.MP.MESSAGE5)

	self.btnOkay = self:AddChild(ImageButton())
	self.btnOkay:SetPosition(0,-box:H()/2-20/2)
	self.btnOkay:SetScale(.7,.7,.7)
	self.btnOkay:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.OKAY)
	self.btnOkay:SetOnClick(function()
		if self.okay_callback ~= nil then
			self.okay_callback()
		end
	end)
end

function DialogMp:SetOkayCallback(callback)
	self.okay_callback = callback
end

return DialogMp