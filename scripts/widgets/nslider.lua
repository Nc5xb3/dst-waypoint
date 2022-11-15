--[[
NSlider (WIP)
By Nc5xb3
Custom slider
]]

local NPanel = require "widgets/npanel"
local ImageButton = require "widgets/imagebutton"

local DEFAULT_THUMB_WIDTH = 10
local DEFAULT_THUMB_HEIGHT = 50

local NSlider = Class(NPanel, function(self, name)
	NPanel._ctor(self, name)
	self.class = {"NSlider"}
	self.onupdate_callback = nil

	self.onfocus = false

	self.value = 0
	self.min = 0
	self.max = 255
	
	self.thumb = self:AddChild(ImageButton("images/ui.xml","black.tex","black.tex","black.tex"))
    self.thumb.scale_on_focus = false
    self.thumb.move_on_click = false
	self.thumb:SetScale(1,1,1)
	self.thumb:SetPosition(0,0)
	self.thumb:ForceImageSize(DEFAULT_THUMB_WIDTH,DEFAULT_THUMB_HEIGHT)
	self.thumb:SetOnDown(function()
		self.drag = true
		self.offset = 0
	end)
	self.thumb:SetWhileDown(function()
		self:Drag()
	end)
	self.thumb.OnLoseFocus = function()
		self.drag = false
	end
end)

function NSlider:Drag()
	local w,h = self:GetSize()
	self.thumb:SetPosition(0,0)
end

function NSlider:SetSize(w,h)
	NSlider._base.SetSize(self,w,h)
	self.thumb:ForceImageSize(DEFAULT_THUMB_WIDTH,h)
end

return NSlider