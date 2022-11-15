--[[
Styler
By Nc5xb3
Example of use of NStyler sort of creating a CSS for NPanels
]]

local NBox = require "util/nbox"
local NStyler = require "util/nstyler"

local Compatibility = require "util/compatibility"
local Widget = require "widgets/widget"

local function Outline(npanel)
	local box = NBox()
	box:SetSize(npanel:GetSize())

	npanel.style = npanel:AddChild(Widget("StyleOutline"))

	npanel.style.t = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.t:SetScale(1,1)
	npanel.style.t:SetPosition(0,box:Y(0),0)
	npanel.style.t:SetSize(npanel:GetSize()[1]+5,1)
	npanel.style.t:SetTint(0,0,0,.3)

	npanel.style.b = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.b:SetScale(1,1)
	npanel.style.b:SetPosition(0,box:Y(box:H()),0)
	npanel.style.b:SetSize(npanel:GetSize()[1]+5,1)
	npanel.style.b:SetTint(0,0,0,.3)
	npanel.style.b:SetRotation(180)

	npanel.style.l = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.l:SetScale(1,1)
	npanel.style.l:SetPosition(box:X(0),0,0)
	npanel.style.l:SetSize(npanel:GetSize()[2]+3,1)
	npanel.style.l:SetTint(0,0,0,.3)
	npanel.style.l:SetRotation(90)

	npanel.style.r = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.r:SetScale(1,1)
	npanel.style.r:SetPosition(box:X(box:W()),0,0)
	npanel.style.r:SetSize(npanel:GetSize()[2]+3,1)
	npanel.style.r:SetTint(0,0,0,.3)
	npanel.style.r:SetRotation(-90)
end

local Styler = Class(NStyler, function(self, skin)
	NStyler._ctor(self)

	self:AddStyle({".*"}, function(npanel)
		npanel.style = npanel:AddChild(Image("images/ui.xml", "black.tex"))
		npanel.style:SetScale(1,1,1)
		npanel.style:SetPosition(0,0,0)
		npanel.style:SetSize(npanel:GetSize())
		npanel.style:SetTint(1,1,1,.5)
		if not Compatibility.DST then
			npanel.style.inst:AddTag("NOCLICK")
			-- npanel.style:SetClickable(false)
		end
	end)

	if skin == 1 then
		self:AddStyle({"NPanel", "Frame"}, function(npanel)
			npanel.style = npanel:AddChild(Widget("StyleFrame"))
			local box = NBox(npanel:GetSize())
			local expand = 10

			npanel.style.top = npanel.style:AddChild(Image("images/npanel.xml", "top.tex"))
			npanel.style.top:SetPosition(0,box:Y(0)+expand*2.5,0)
			npanel.style.top.inst:AddTag("NOCLICK")
			-- npanel.style.top:SetClickable(false)

			npanel.style.bottom = npanel.style:AddChild(Image("images/npanel.xml", "bottom.tex"))
			npanel.style.bottom:SetPosition(0,box:Y(box:H())-expand*3,0)
			npanel.style.bottom.inst:AddTag("NOCLICK")
			-- npanel.style.bottom:SetClickable(false)

			npanel.style.topleft = npanel.style:AddChild(Image("images/npanel.xml", "topleft.tex"))
			npanel.style.topleft:SetPosition(box:X(0)-expand/2,box:Y(0)+expand/2,0)
			npanel.style.topleft.inst:AddTag("NOCLICK")
			-- npanel.style.topleft:SetClickable(false)

			npanel.style.topright = npanel.style:AddChild(Image("images/npanel.xml", "topright.tex"))
			npanel.style.topright:SetPosition(box:X(box:W())+expand/2,box:Y(0)+expand/2,0)
			npanel.style.topright.inst:AddTag("NOCLICK")
			-- npanel.style.topright:SetClickable(false)

			npanel.style.botleft = npanel.style:AddChild(Image("images/npanel.xml", "botleft.tex"))
			npanel.style.botleft:SetPosition(box:X(0)-expand/2,box:Y(box:H())-expand/2,0)
			npanel.style.botleft.inst:AddTag("NOCLICK")
			-- npanel.style.botleft:SetClickable(false)

			npanel.style.botright = npanel.style:AddChild(Image("images/npanel.xml", "botright.tex"))
			npanel.style.botright:SetPosition(box:X(box:W())+expand/2,box:Y(box:H())-expand/2,0)
			npanel.style.botright.inst:AddTag("NOCLICK")
			-- npanel.style.botright:SetClickable(false)

			npanel.style.tickleft = npanel.style:AddChild(Image("images/npanel.xml", "tickleft.tex"))
			npanel.style.tickleft:SetPosition(box:X(box:W()/4),box:Y(0)+expand,0)
			npanel.style.tickleft.inst:AddTag("NOCLICK")
			-- npanel.style.tickleft:SetClickable(false)

			npanel.style.tickright = npanel.style:AddChild(Image("images/npanel.xml", "tickright.tex"))
			npanel.style.tickright:SetPosition(box:X(box:W()*.75),box:Y(0)+expand,0)
			npanel.style.tickright.inst:AddTag("NOCLICK")
			-- npanel.style.tickright:SetClickable(false)

			npanel.style.back = npanel.style:AddChild(Image("images/ui.xml", "black.tex"))
			npanel.style.back:SetScale(1,1)
			npanel.style.back:SetSize(npanel:GetSize()[1]+expand,npanel:GetSize()[2]+expand)
			npanel.style.back.inst:AddTag("NOCLICK")
			-- npanel.style.back:SetClickable(false)

			npanel.style.front = npanel.style:AddChild(Image("images/npanelbg.xml", "bg.tex"))
			npanel.style.front:SetScale(1,1)
			npanel.style.front:SetSize(npanel:GetSize())
			if not Compatibility.DST then
				npanel.style.front.inst:AddTag("NOCLICK")
				-- npanel.style.front:SetClickable(false)
			end
		end)

		self:AddStyle({"NPanel", "ListItem"}, function(npanel)
			Outline(npanel)
		end)

		self:AddStyle({"NInput"}, function(npanel)
			npanel.style = npanel:AddChild(Image("images/ninput.xml", "ninput.tex"))
			npanel.style:SetScale(1,1)
			npanel.style:SetSize(npanel:GetSize())
			npanel.style:SetTint(0,0,0,.5)
			if not Compatibility.DST then
				npanel.style.inst:AddTag("NOCLICK")
				-- npanel.style:SetClickable(false)
			end
			
			npanel:SetFont(TALKINGFONT)
			npanel:SetFontSize(24)
		end)

		self:AddStyle({"NColourPalette"}, function(npanel)
			Outline(npanel)
		end)

	end
end)

return Styler