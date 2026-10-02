--[[
NColourPalette
By Nc5xb3
HSV Colour palette
]]

local NPanel = require "widgets/npanel"
local NBox = require "util/nbox"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()

local NColourPalette = Class(NPanel, function(self, name, span)
	NPanel._ctor(self, name)
	self.class = {"NColourPalette"}

	self.click_callback = nil

	self.spanHS = .9
	self.spanV = .09
	self.span = span or 8

	self.h = 0 -- 0-360
	self.s = 1 -- 0-1
	self.v = 1 -- 0-1
end)

function NColourPalette:SetSize(w,h)
	h = h - (h % self.span) -- Remove excess height
	NColourPalette._base.SetSize(self,w,h)
	w = w - 1
	h = h - 1

	self.widthHS = w * self.spanHS
	self.widthV = w * self.spanV

	self.offsetHS = -(w - self.widthHS) / 2
	self.offsetV = (w - self.widthV) / 2

	local maxColHS = self.widthHS / self.span
	local maxRow = math.ceil(h / self.span)

	self.paletteHS = {}
	self.paletteV = {}

	local boxHS = NBox(self.widthHS, h)

	for i=1,maxColHS do
		self.paletteHS[i] = {}
		for j=1,maxRow do
			local pHS = self:AddChild(ImageButton("images/white.xml","white.tex","white.tex","white.tex"))
			pHS.scale_on_focus = false
			pHS.move_on_click = false
			pHS:SetScale(1,1,1)
			pHS:SetPosition(self.offsetHS+boxHS:GridX(i,maxColHS),boxHS:GridY(j,maxRow))
			pHS:ForceImageSize(boxHS:GridW(maxColHS),boxHS:GridH(maxRow))
			self.paletteHS[i][j] = pHS
		end
	end

	for i=1,maxRow do
		local pV = self:AddChild(ImageButton("images/white.xml","white.tex","white.tex","white.tex"))
		local c = 1 - (i-1)/(maxRow-1)
		pV.scale_on_focus = false
		pV.move_on_click = false
		pV:SetScale(1,1,1)
		pV:SetPosition(self.offsetV,boxHS:GridY(i,maxRow))
		pV:ForceImageSize(self.widthV,boxHS:GridH(maxRow))
		pV:SetImageNormalColour(c,c,c,1)
		pV:SetImageFocusColour(c,c,c,1)
		pV:SetOnClick(function()
			self.v = c
			self:UpdatePalette()
			if self.click_callback ~= nil then
				self.click_callback()
			end
		end)
		self.paletteV[i] = pV
	end

	self.markerHS = self:AddChild(Image("images/white.xml", "white.tex"))
	self.markerHS:SetScale(1,1)
	self.markerHS:SetSize(2,2)
	self.markerHS:SetTint(0,0,0,1)
	self.markerV = self:AddChild(Image("images/white.xml", "white.tex"))
	self.markerV:SetScale(1,1)
	self.markerV:SetSize(2,2)
	self.markerV:SetTint(0,0,0,1)

	self:UpdatePalette()
end

function NColourPalette:UpdatePalette()
	if self.paletteHS ~= nil then
		self:UpdateMarkers()
		local numCol = #self.paletteHS
		for i=1,numCol do
			local col = self.paletteHS[i]
			local numRow = #col
			local hue = 359*(i-1)/(numCol-1)
			for j=1,numRow do
				local pHS = col[j]
				local h,s,v = hue,1-(j-1)/(numRow-1),self.v
				local r,g,b = self:HSVtoRGB(h,s,v)
				pHS:SetImageNormalColour(r,g,b,1)
				pHS:SetImageFocusColour(r,g,b,1)
				pHS:SetOnClick(function()
					self.h = h
					self.s = s
					self.v = v
					self:UpdateMarkers()
					if self.click_callback ~= nil then
						self.click_callback()
					end
				end)
			end
		end
	end
end

function NColourPalette:UpdateMarkers()
	local size = self:GetSize()
	local xHS = self.offsetHS + (self.widthHS - self.widthHS % self.span) * self.h / 360 - self.widthHS / 2

	self.markerHS:SetPosition(xHS, size[2] * self.s - size[2] / 2)
	self.markerV:SetPosition(self.offsetV, size[2] * self.v - size[2] / 2)

	if self.v > .5 then
		self.markerV:SetTint(0,0,0,1)
		self.markerHS:SetTint(0,0,0,1)
	else
		self.markerV:SetTint(1,1,1,1)
		self.markerHS:SetTint(1,1,1,1)
	end

end

function NColourPalette:SetClickCallback(callback)
	self.click_callback = callback
end

function NColourPalette:SetHSV(h,s,v)
	self.h = h
	self.s = s
	self.v = v
	self:UpdatePalette()
end

function NColourPalette:GetRGB()
	return self:HSVtoRGB(self.h, self.s, self.v)
end

function NColourPalette:SetRGB(r,g,b)
	local h,s,v = self:RGBtoHSV(r,g,b)
	self:SetHSV(h,s,v)
end

function NColourPalette:RGBtoHSV(r,g,b)
	local min, max, delta
	local h,s,v
	
	min = math.min(r,g,b)
	max = math.max(r,g,b)
	
	v = max
	delta = max - min

	if delta == 0 then
		return 0,0,v
	end

	if max ~= 0 then
		s = delta / max
	else
		return 0,0,v
	end

	if r == max then
		h = (g-b)/delta
	elseif g == max then
		h = 2+(b-r)/delta
	else
		h = 4+(r-g)/delta
	end

	h = h * 60
	if h < 0 then
		h = h + 360
	end
	return h,s,v
end

function NColourPalette:HSVtoRGB(h,s,v)
	local i
	local f, p, q, t

	if s == 0 then
		return v, v, v
	end

	h = h / 60
	i = math.floor(h)
	f = h-i
	p = v*(1-s);
	q = v*(1-s*f);
	t = v*(1-s*(1-f))

	if i == 0 then
		return v, t, p
	elseif i == 1 then
		return q, v, p
	elseif i == 2 then
		return p, v, t
	elseif i == 3 then
		return p, q, v
	elseif i == 4 then
		return t, p, v
	else
		return v, p, q
	end
end

return NColourPalette