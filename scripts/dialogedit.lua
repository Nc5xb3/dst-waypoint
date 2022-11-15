--[[
DialogEdit
By Nc5xb3
Dialog to edit a waypoint
]]

local NPanel = require "widgets/npanel"
local NInput = require "widgets/ninput"
local NColourPalette = require "widgets/ncolourpalette"
local Styler = require "styler"
local NBox = require "util/nbox"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()
local Text = Compatibility:Text()

local DialogEdit = Class(NPanel, function(self,w,h,skin,colourVariety)
    NPanel._ctor(self, "DialogEdit")
	self.colourVariety = colourVariety

    self:SetSuccessCallback(nil)
    self:SetCancelCallback(nil)
    self:SetDeleteCallback(nil)

	self:InitialiseComponents(w or 400,h or 300)
	Styler(skin or 1):ApplyStyle(self)
end)

function DialogEdit:InitialiseComponents(w,h)
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
	self.lblTitle:SetPosition(0,box:GridY(1,maxRows),0)
	self.lblTitle:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.TITLE)

	self.lblName = self:AddChild(Text(TALKINGFONT,24))
	self.lblName:SetPosition(box:GridX(2,maxCols),box:GridY(2,maxRows))
	self.lblName:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.NAME)

	self.inputName = self:AddChild(NInput("WaypointName"))
	self.inputName:SetPosition(box:GridX(7,maxCols),box:GridY(2,maxRows)) -- 1[2]3 | 4[7]10
	self.inputName:SetSize(box:GridW(maxCols)*7-10,box:GridH(maxRows)-10)

	self.lblCoord = self:AddChild(Text(TALKINGFONT,24))
	self.lblCoord:SetPosition(box:GridX(2,maxCols),box:GridY(3,maxRows))
	self.lblCoord:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.COORDINATES)

	self.inputX = self:AddChild(NInput("CoordX"))
	self.inputX:SetPosition(box:GridX(5,maxCols),box:GridY(3,maxRows)) -- 1[2]3 | 4[7]10
	self.inputX:SetSize(box:GridW(maxCols)*3-10,box:GridH(maxRows)-20)
	self.inputX:SetCharacterFilter("0123456789-.")

	self.inputZ = self:AddChild(NInput("CoordZ"))
	self.inputZ:SetPosition(box:GridX(9,maxCols),box:GridY(3,maxRows)) -- 1[2]3 | 4[7]10
	self.inputZ:SetSize(box:GridW(maxCols)*3-10,box:GridH(maxRows)-20)
	self.inputZ:SetCharacterFilter("0123456789-.")

	self.lblColour = self:AddChild(Text(TALKINGFONT,24))
	self.lblColour:SetPosition(box:GridX(2,maxCols),box:GridY(4,maxRows))
	self.lblColour:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.COLOUR)

	self.imgFlag = self:AddChild(ImageButton("images/flag.xml","flag.tex","flag.tex","flag.tex"))
	self.imgFlag:SetTooltip(STRINGS.WAYPOINT.UI.DIALOG.EDIT.RANDOMIZE)
	self.imgFlag:SetPosition(box:GridX(2,maxCols),box:GridY(5.3,maxRows))
    self.imgFlag:SetNormalScale(.3)
	self.imgFlag:SetFocusScale(.34)
	self.imgFlag:SetOnClick(function()
		local r = math.random()*.7 + .3
		local g = math.random()*.7 + .3
		local b = math.random()*.7 + .3
		self.palette:SetRGB(r,g,b)
		self.inputName.input:SetColour(r,g,b,1)
		self.imgFlag:SetImageNormalColour(r,g,b,1)
		self.imgFlag:SetImageFocusColour(r,g,b,1)
	end)

    self.palette = self:AddChild(NColourPalette("ColourPalette", self.colourVariety))
	self.palette:SetPosition(box:GridX(7,maxCols),box:GridY(5,maxRows)) -- 1[2]3 | 4[7]10
	self.palette:SetSize(box:GridW(maxCols)*6.5,box:GridH(maxRows)*2.5)
	self.palette:SetClickCallback(function()
		local r,g,b = self.palette:GetRGB()
		self.inputName.input:SetColour(r,g,b,1)
		self.imgFlag:SetImageNormalColour(r,g,b,1)
		self.imgFlag:SetImageFocusColour(r,g,b,1)
	end)

    -- Not working
	-- self.lblRed = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblRed:SetPosition(box:GridX(4,maxCols),box:GridY(4,maxRows))
	-- self.lblRed:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.RED)

	-- self.sliderRed = self:AddChild(NSlider("SliderRed"))
	-- self.sliderRed:SetPosition(box:GridX(7,maxCols),box:GridY(4,maxRows))
	-- self.sliderRed:SetSize(box:GridW(maxCols)*5-10,30)

	-- self.lblRedValue = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblRedValue:SetPosition(box:GridX(maxCols,maxCols),box:GridY(4,maxRows))
	-- self.lblRedValue:SetString("255")

	-- self.lblGreen = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblGreen:SetPosition(box:GridX(4,maxCols),box:GridY(5,maxRows))
	-- self.lblGreen:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.GREEN)

	-- self.sliderGreen = self:AddChild(NSlider("SliderGreen"))
	-- self.sliderGreen:SetPosition(box:GridX(7,maxCols),box:GridY(5,maxRows))
	-- self.sliderGreen:SetSize(box:GridW(maxCols)*5-10,30)

	-- self.lblGreenValue = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblGreenValue:SetPosition(box:GridX(maxCols,maxCols),box:GridY(5,maxRows))
	-- self.lblGreenValue:SetString("255")

	-- self.lblBlue = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblBlue:SetPosition(box:GridX(4,maxCols),box:GridY(6,maxRows))
	-- self.lblBlue:SetString(STRINGS.WAYPOINT.UI.DIALOG.EDIT.BLUE)

	-- self.sliderBlue = self:AddChild(NSlider("SliderBlue"))
	-- self.sliderBlue:SetPosition(box:GridX(7,maxCols),box:GridY(6,maxRows))
	-- self.sliderBlue:SetSize(box:GridW(maxCols)*5-10,30)

	-- self.lblBlueValue = self:AddChild(Text(TALKINGFONT,20))
	-- self.lblBlueValue:SetPosition(box:GridX(maxCols,maxCols),box:GridY(6,maxRows))
	-- self.lblBlueValue:SetString("255")

	--

	self.btnDelete = self:AddChild(ImageButton("images/nuiwp.xml", "delete.tex", "delete.tex", "delete.tex"))
	self.btnDelete:SetTooltip(STRINGS.WAYPOINT.UI.DIALOG.OPTION.DELETE)
	self.btnDelete:SetPosition(box:GridX(maxCols,maxCols),box:GridY(1,maxRows))
	self.btnDelete:SetNormalScale(.5)
	self.btnDelete:SetFocusScale(.57)
	self.btnDelete:SetImageNormalColour(.9,.9,.9,1)
	self.btnDelete:SetImageFocusColour(1,1,1,1)
	self.btnDelete:SetOnClick(function()
		if self.delete_callback ~= nil then
			self.delete_callback()
		end
	end)


	self.btnSave = self:AddChild(ImageButton())
	self.btnSave:SetPosition(-box:W()/4,-box:H()/2-20/2)
	self.btnSave:SetScale(.7,.7,.7)
	self.btnSave:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.SAVE)
	self.btnSave:SetOnClick(function()
		if self.success_callback ~= nil then
			self.success_callback()
		end
	end)

	self.btnCancel = self:AddChild(ImageButton())
	self.btnCancel:SetPosition(box:W()/4,-box:H()/2-20/2)
	self.btnCancel:SetScale(.7,.7,.7)
	self.btnCancel:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.CANCEL)
	self.btnCancel:SetOnClick(function()
		if self.cancel_callback ~= nil then
			self.cancel_callback()
		end
	end)
end

function DialogEdit:SetWaypoint(waypoint)
	if waypoint ~= nil then
		self.inputName.input:SetText(waypoint.name)
		self.inputName.input:SetColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		self.inputX.input:SetText(tonumber(string.format("%.3f", waypoint.coord.x)))
		self.inputZ.input:SetText(tonumber(string.format("%.3f", waypoint.coord.z)))

		-- self.lblRedValue:SetString(math.floor(.5 + waypoint.colour.r * 255))
		-- self.lblGreenValue:SetString(math.floor(.5 + waypoint.colour.g * 255))
		-- self.lblBlueValue:SetString(math.floor(.5 + waypoint.colour.b * 255))

		-- self.imgFlag:SetTint(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		self.imgFlag:SetImageNormalColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		self.imgFlag:SetImageFocusColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)

		self.palette:SetRGB(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b)
	end
end

function DialogEdit:SetSuccessCallback(callback)
	self.success_callback = callback
end

function DialogEdit:SetCancelCallback(callback)
	self.cancel_callback = callback
end

function DialogEdit:SetDeleteCallback(callback)
	self.delete_callback = callback
end

return DialogEdit