--[[
Styler
By Nc5xb3
Example of use of NStyler sort of creating a CSS for NPanels
]]

local NBox = require "util/nbox"
local NStyler = require "util/nstyler"

local Compatibility = require "util/compatibility"
local Widget = require "widgets/widget"

-- Constants
local OUTLINE_WIDTH_OFFSET = 5
local OUTLINE_HEIGHT_OFFSET = 3
local OUTLINE_TINT_R = 0
local OUTLINE_TINT_G = 0
local OUTLINE_TINT_B = 0
local OUTLINE_TINT_A = 0.3
local BACKGROUND_TINT_R = 1
local BACKGROUND_TINT_G = 1
local BACKGROUND_TINT_B = 1
local BACKGROUND_TINT_A = 0.5
local INPUT_TINT_R = 0
local INPUT_TINT_G = 0
local INPUT_TINT_B = 0
local INPUT_TINT_A = 0.5
local FRAME_EXPAND = 10
local FRAME_TOP_MULTIPLIER = 2.5
local FRAME_BOTTOM_MULTIPLIER = 3
local FRAME_TICK_LEFT_RATIO = 0.25
local FRAME_TICK_RIGHT_RATIO = 0.75

-- Helper function to add NOCLICK tag for non-DST compatibility
local function AddNoClickTag(widget)
	if widget and widget.inst and not Compatibility.DST then
		widget.inst:AddTag("NOCLICK")
	end
end

local function Outline(npanel)
	local box = NBox()
	box:SetSize(npanel:GetSize())
	local panelSize = npanel:GetSize()

	npanel.style = npanel:AddChild(Widget("StyleOutline"))

	-- Top line
	npanel.style.t = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.t:SetScale(1, 1)
	npanel.style.t:SetPosition(0, box:Y(0), 0)
	npanel.style.t:SetSize(panelSize[1] + OUTLINE_WIDTH_OFFSET, 1)
	npanel.style.t:SetTint(OUTLINE_TINT_R, OUTLINE_TINT_G, OUTLINE_TINT_B, OUTLINE_TINT_A)

	-- Bottom line
	npanel.style.b = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.b:SetScale(1, 1)
	npanel.style.b:SetPosition(0, box:Y(box:H()), 0)
	npanel.style.b:SetSize(panelSize[1] + OUTLINE_WIDTH_OFFSET, 1)
	npanel.style.b:SetTint(OUTLINE_TINT_R, OUTLINE_TINT_G, OUTLINE_TINT_B, OUTLINE_TINT_A)
	npanel.style.b:SetRotation(180)

	-- Left line
	npanel.style.l = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.l:SetScale(1, 1)
	npanel.style.l:SetPosition(box:X(0), 0, 0)
	npanel.style.l:SetSize(panelSize[2] + OUTLINE_HEIGHT_OFFSET, 1)
	npanel.style.l:SetTint(OUTLINE_TINT_R, OUTLINE_TINT_G, OUTLINE_TINT_B, OUTLINE_TINT_A)
	npanel.style.l:SetRotation(90)

	-- Right line
	npanel.style.r = npanel.style:AddChild(Image("images/nline.xml", "nline.tex"))
	npanel.style.r:SetScale(1, 1)
	npanel.style.r:SetPosition(box:X(box:W()), 0, 0)
	npanel.style.r:SetSize(panelSize[2] + OUTLINE_HEIGHT_OFFSET, 1)
	npanel.style.r:SetTint(OUTLINE_TINT_R, OUTLINE_TINT_G, OUTLINE_TINT_B, OUTLINE_TINT_A)
	npanel.style.r:SetRotation(-90)
end

local Styler = Class(NStyler, function(self, skin)
	NStyler._ctor(self)

	self:AddStyle({".*"}, function(npanel)
		npanel.style = npanel:AddChild(Image("images/ui.xml", "black.tex"))
		npanel.style:SetScale(1, 1, 1)
		npanel.style:SetPosition(0, 0, 0)
		npanel.style:SetSize(npanel:GetSize())
		npanel.style:SetTint(BACKGROUND_TINT_R, BACKGROUND_TINT_G, BACKGROUND_TINT_B, BACKGROUND_TINT_A)
		AddNoClickTag(npanel.style)
	end)

	if skin == 1 then
		self:AddStyle({"NPanel", "Frame"}, function(npanel)
			npanel.style = npanel:AddChild(Widget("StyleFrame"))
			local box = NBox(npanel:GetSize())
			local expand = FRAME_EXPAND
			local panelSize = npanel:GetSize()

			-- Top border
			npanel.style.top = npanel.style:AddChild(Image("images/npanel.xml", "top.tex"))
			npanel.style.top:SetPosition(0, box:Y(0) + expand * FRAME_TOP_MULTIPLIER, 0)
			AddNoClickTag(npanel.style.top)

			-- Bottom border
			npanel.style.bottom = npanel.style:AddChild(Image("images/npanel.xml", "bottom.tex"))
			npanel.style.bottom:SetPosition(0, box:Y(box:H()) - expand * FRAME_BOTTOM_MULTIPLIER, 0)
			AddNoClickTag(npanel.style.bottom)

			-- Top-left corner
			npanel.style.topleft = npanel.style:AddChild(Image("images/npanel.xml", "topleft.tex"))
			npanel.style.topleft:SetPosition(box:X(0) - expand / 2, box:Y(0) + expand / 2, 0)
			AddNoClickTag(npanel.style.topleft)

			-- Top-right corner
			npanel.style.topright = npanel.style:AddChild(Image("images/npanel.xml", "topright.tex"))
			npanel.style.topright:SetPosition(box:X(box:W()) + expand / 2, box:Y(0) + expand / 2, 0)
			AddNoClickTag(npanel.style.topright)

			-- Bottom-left corner
			npanel.style.botleft = npanel.style:AddChild(Image("images/npanel.xml", "botleft.tex"))
			npanel.style.botleft:SetPosition(box:X(0) - expand / 2, box:Y(box:H()) - expand / 2, 0)
			AddNoClickTag(npanel.style.botleft)

			-- Bottom-right corner
			npanel.style.botright = npanel.style:AddChild(Image("images/npanel.xml", "botright.tex"))
			npanel.style.botright:SetPosition(box:X(box:W()) + expand / 2, box:Y(box:H()) - expand / 2, 0)
			AddNoClickTag(npanel.style.botright)

			-- Left tick
			npanel.style.tickleft = npanel.style:AddChild(Image("images/npanel.xml", "tickleft.tex"))
			npanel.style.tickleft:SetPosition(box:X(box:W() * FRAME_TICK_LEFT_RATIO), box:Y(0) + expand, 0)
			AddNoClickTag(npanel.style.tickleft)

			-- Right tick
			npanel.style.tickright = npanel.style:AddChild(Image("images/npanel.xml", "tickright.tex"))
			npanel.style.tickright:SetPosition(box:X(box:W() * FRAME_TICK_RIGHT_RATIO), box:Y(0) + expand, 0)
			AddNoClickTag(npanel.style.tickright)

			-- Background
			npanel.style.back = npanel.style:AddChild(Image("images/ui.xml", "black.tex"))
			npanel.style.back:SetScale(1, 1)
			npanel.style.back:SetSize(panelSize[1] + expand, panelSize[2] + expand)
			AddNoClickTag(npanel.style.back)

			-- Front panel
			npanel.style.front = npanel.style:AddChild(Image("images/npanelbg.xml", "bg.tex"))
			npanel.style.front:SetScale(1, 1)
			npanel.style.front:SetSize(panelSize)
			AddNoClickTag(npanel.style.front)
		end)

		self:AddStyle({"NPanel", "ListItem"}, function(npanel)
			Outline(npanel)
		end)

		self:AddStyle({"NInput"}, function(npanel)
			npanel.style = npanel:AddChild(Image("images/ninput.xml", "ninput.tex"))
			npanel.style:SetScale(1, 1)
			npanel.style:SetSize(npanel:GetSize())
			npanel.style:SetTint(INPUT_TINT_R, INPUT_TINT_G, INPUT_TINT_B, INPUT_TINT_A)
			AddNoClickTag(npanel.style)
			
			npanel:SetFont(TALKINGFONT)
			npanel:SetFontSize(24)
		end)

		self:AddStyle({"NColourPalette"}, function(npanel)
			Outline(npanel)
		end)

	end
end)

return Styler