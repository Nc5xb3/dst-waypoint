--[[
DialogIndicatorArea
Compact panel (bottom-right of the screen) to choose the shape
(square / rectangle / circle / oval) and size of the area that off-screen waypoint
indicators sit on. While open:
  * a dotted outline of the area is drawn on screen,
  * the other waypoint windows are hidden (see MainWp:OpenIndicatorAreaDialog),
  * indicators are temporarily switched on so you can watch them follow.
]]

local NPanel = require "widgets/npanel"
local Widget = require "widgets/widget"
local Styler = require "styler"
local NBox = require "util/nbox"
local IndicatorArea = require "indicatorarea"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()
local Text = Compatibility:Text()

local DIALOG_W, DIALOG_H = 300, 210
-- Gap from the right screen edge, and height kept clear at the bottom for the
-- HUD buttons there (waypoint HUD button, map, rotate). In UI units, scaled
-- with the screen like the panel itself.
local RIGHT_MARGIN = 45
local BOTTOM_CLEARANCE = 230

local TITLE_FONT_SIZE = 24
local LABEL_FONT_SIZE = 20
local DESC_FONT_SIZE = 15
local DESC_COLOUR = {.85, .8, .65, 1}

local PREVIEW_DOTS = 120
local PREVIEW_DOT_SIZE = 6
local PREVIEW_COLOUR = {1, .85, .35, .9}

local DialogIndicatorArea = Class(NPanel, function(self, w, h, skin, mainwp)
	NPanel._ctor(self, "DialogIndicatorArea")
	self.skin = skin or 1
	self.mainwp = mainwp

	self:SetCancelCallback(nil)

	self:InitialiseComponents(w or DIALOG_W, h or DIALOG_H)
	Styler(skin or 1):ApplyStyle(self)
	self:CreatePreview()
	self:RefreshValues()
end)

local function Strings()
	return STRINGS.WAYPOINT.UI.DIALOG.INDICATOR_AREA
end

local function ArrowButton(tex)
	local button = ImageButton("images/nuiwp.xml", tex, tex, tex)
	button:SetNormalScale(.45)
	button:SetFocusScale(.52)
	button:SetImageNormalColour(.9, .9, .9, 1)
	button:SetImageFocusColour(1, 1, 1, 1)
	return button
end

function DialogIndicatorArea:InitialiseComponents(w, h)
	-- Anchored to the bottom-right corner of the screen. The panel is scaled
	-- proportionally but its position is in screen pixels, so scale the
	-- offsets too (otherwise it spills off the right edge on big screens).
	self:SetVAnchor(ANCHOR_BOTTOM)
	self:SetHAnchor(ANCHOR_RIGHT)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)
	local screenW, screenH = TheSim:GetScreenSize()
	local uiScale = math.min(screenW / (rawget(_G, "RESOLUTION_X") or 1280), screenH / (rawget(_G, "RESOLUTION_Y") or 720))
	self:SetPosition(-(w / 2 + RIGHT_MARGIN) * uiScale, (h / 2 + BOTTOM_CLEARANCE) * uiScale)
	self:SetSize(w, h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())
	local maxRows = 5
	local strs = Strings()
	local left = -box:W() / 2 + 18
	local labelWidth = box:W() * .36
	-- Value column: arrows at +-55 around it, kept inside the panel
	local controlX = box:W() / 4 - 5
	local arrowGap = 55

	-- Title
	self.lblTitle = self:AddChild(Text(TALKINGFONT, TITLE_FONT_SIZE))
	self.lblTitle:SetPosition(0, box:GridY(1, maxRows), 0)
	self.lblTitle:SetString(strs.TITLE)

	local function AddLabel(row, str)
		local label = self:AddChild(Text(TALKINGFONT, LABEL_FONT_SIZE))
		label:SetRegionSize(labelWidth, 26)
		label:SetHAlign(ANCHOR_LEFT)
		label:SetPosition(left + labelWidth / 2, box:GridY(row, maxRows))
		label:SetString(str)
		return label
	end

	-- Shape: [<] Rectangle [>]
	self.lblShape = AddLabel(2, strs.SHAPE)
	self.btnShapePrev = self:AddChild(ArrowButton("left.tex"))
	self.btnShapePrev:SetPosition(controlX - arrowGap, box:GridY(2, maxRows))
	self.btnShapePrev:SetOnClick(function() self:CycleShape(-1) end)

	self.lblShapeValue = self:AddChild(Text(TALKINGFONT, LABEL_FONT_SIZE))
	self.lblShapeValue:SetPosition(controlX, box:GridY(2, maxRows))

	self.btnShapeNext = self:AddChild(ArrowButton("right.tex"))
	self.btnShapeNext:SetPosition(controlX + arrowGap, box:GridY(2, maxRows))
	self.btnShapeNext:SetOnClick(function() self:CycleShape(1) end)

	-- Size: [<] 50% [>]
	self.lblSize = AddLabel(3, strs.SIZE)
	self.btnSmaller = self:AddChild(ArrowButton("left.tex"))
	self.btnSmaller:SetPosition(controlX - arrowGap, box:GridY(3, maxRows))
	self.btnSmaller:SetOnClick(function() self:ChangeSize(-IndicatorArea.SIZE_STEP) end)

	self.lblSizeValue = self:AddChild(Text(TALKINGFONT, LABEL_FONT_SIZE))
	self.lblSizeValue:SetPosition(controlX, box:GridY(3, maxRows))

	self.btnLarger = self:AddChild(ArrowButton("right.tex"))
	self.btnLarger:SetPosition(controlX + arrowGap, box:GridY(3, maxRows))
	self.btnLarger:SetOnClick(function() self:ChangeSize(IndicatorArea.SIZE_STEP) end)

	-- Names: [<] Always / On hover [>]
	self.lblNames = AddLabel(4, strs.NAMES)
	self.btnNamesPrev = self:AddChild(ArrowButton("left.tex"))
	self.btnNamesPrev:SetPosition(controlX - arrowGap, box:GridY(4, maxRows))
	self.btnNamesPrev:SetOnClick(function() self:ToggleNames() end)

	self.lblNamesValue = self:AddChild(Text(TALKINGFONT, LABEL_FONT_SIZE))
	self.lblNamesValue:SetPosition(controlX, box:GridY(4, maxRows))

	self.btnNamesNext = self:AddChild(ArrowButton("right.tex"))
	self.btnNamesNext:SetPosition(controlX + arrowGap, box:GridY(4, maxRows))
	self.btnNamesNext:SetOnClick(function() self:ToggleNames() end)

	-- One-line hint
	self.lblNote = self:AddChild(Text(TALKINGFONT, DESC_FONT_SIZE))
	self.lblNote:SetRegionSize(box:W() - 30, 22)
	self.lblNote:SetColour(DESC_COLOUR[1], DESC_COLOUR[2], DESC_COLOUR[3], DESC_COLOUR[4])
	self.lblNote:SetPosition(0, box:GridY(5, maxRows))
	self.lblNote:SetString(strs.PREVIEW_NOTE)

	-- Close (smaller than usual to keep the panel compact)
	self.btnClose = self:AddChild(ImageButton())
	self.btnClose:SetPosition(0, -box:H() / 2 - 14)
	self.btnClose:SetScale(.55, .55, .55)
	self.btnClose:SetText(STRINGS.WAYPOINT.UI.DIALOG.OPTION.CLOSE)
	self.btnClose:SetOnClick(function()
		if self.cancel_callback ~= nil then
			self.cancel_callback()
		end
	end)
end

function DialogIndicatorArea:GetSettings()
	if self.mainwp and self.mainwp.getSettings then
		return self.mainwp.getSettings()
	end
	return { indicator_shape = IndicatorArea.shape, indicator_area_size = IndicatorArea.size }
end

function DialogIndicatorArea:SetSetting(key, value)
	if self.mainwp and self.mainwp.setSetting then
		self.mainwp.setSetting(key, value)
	end
	self:RefreshValues()
end

function DialogIndicatorArea:CycleShape(direction)
	local current = self:GetSettings().indicator_shape or IndicatorArea.DEFAULT_SHAPE
	local shapes = IndicatorArea.SHAPES
	local index = 1
	for i, shape in ipairs(shapes) do
		if shape == current then
			index = i
			break
		end
	end
	index = (index - 1 + (direction or 1)) % #shapes + 1
	self:SetSetting("indicator_shape", shapes[index])
end

function DialogIndicatorArea:ToggleNames()
	local current = self:GetSettings().indicator_names or "hover"
	self:SetSetting("indicator_names", current == "hover" and "always" or "hover")
end

function DialogIndicatorArea:ChangeSize(delta)
	local current = self:GetSettings().indicator_area_size or IndicatorArea.DEFAULT_SIZE
	self:SetSetting("indicator_area_size", IndicatorArea:ClampSize(current + delta))
end

function DialogIndicatorArea:RefreshValues()
	local settings = self:GetSettings()
	local shape = settings.indicator_shape or IndicatorArea.DEFAULT_SHAPE
	local size = settings.indicator_area_size or IndicatorArea.DEFAULT_SIZE

	self.lblShapeValue:SetString(DialogIndicatorArea.ShapeName(shape))
	self.lblSizeValue:SetString(tostring(size) .. "%")
	local strs = Strings()
	self.lblNamesValue:SetString(settings.indicator_names == "hover" and strs.NAMES_HOVER or strs.NAMES_ALWAYS)

	if size <= IndicatorArea.MIN_SIZE then self.btnSmaller:Disable() else self.btnSmaller:Enable() end
	if size >= IndicatorArea.MAX_SIZE then self.btnLarger:Disable() else self.btnLarger:Enable() end

	self:UpdatePreview()
end

function DialogIndicatorArea.ShapeName(shape)
	local strs = Strings()
	if shape == "square" then
		return strs.SHAPE_SQUARE
	elseif shape == "ellipse" then
		return strs.SHAPE_ELLIPSE
	elseif shape == "circle" then
		return strs.SHAPE_CIRCLE
	end
	return strs.SHAPE_RECTANGLE
end

-- Preview -----------------------------------------------------------------
-- Drawn in the same screen space as the indicators (bottom-left anchored
-- child of the indicator manager), using the same IndicatorArea:GetBox, so
-- the outline is exactly where indicator centres sit.

function DialogIndicatorArea:CreatePreview()
	local parent = self.mainwp and self.mainwp.im
	if parent == nil then
		return
	end
	self.preview = parent:AddChild(Widget("IndicatorAreaPreview"))
	self.preview:SetVAnchor(ANCHOR_BOTTOM)
	self.preview:SetHAnchor(ANCHOR_LEFT)
	self.preview:SetClickable(false)
	self.previewDots = {}
	for i = 1, PREVIEW_DOTS do
		local dot = self.preview:AddChild(Image("images/white.xml", "white.tex"))
		dot:SetSize(PREVIEW_DOT_SIZE, PREVIEW_DOT_SIZE)
		dot:SetTint(PREVIEW_COLOUR[1], PREVIEW_COLOUR[2], PREVIEW_COLOUR[3], PREVIEW_COLOUR[4])
		dot:SetClickable(false)
		self.previewDots[i] = dot
	end
end

function DialogIndicatorArea:UpdatePreview()
	if self.preview == nil then
		return
	end
	local screenW, screenH = TheSim:GetScreenSize()
	local cx, cy, hx, hy = IndicatorArea:GetBox(screenW, screenH)
	local points = IndicatorArea:SampleOutline(cx, cy, hx, hy, #self.previewDots)
	for i, dot in ipairs(self.previewDots) do
		local p = points[i]
		if p then
			dot:SetPosition(p[1], p[2], 0)
			dot:Show()
		else
			dot:Hide()
		end
	end
end

function DialogIndicatorArea:SetCancelCallback(callback)
	self.cancel_callback = callback
end

function DialogIndicatorArea:Kill()
	if self.preview ~= nil then
		self.preview:Kill()
		self.preview = nil
	end
	if self.mainwp and self.mainwp.dialogIndicatorArea == self then
		self.mainwp.dialogIndicatorArea = nil
	end
	NPanel.Kill(self)
end

-- Controller navigation (screens/waypointcontrollerscreen.lua):
-- each setting is one item, left/right changes it
local VALUE_BOX_W, VALUE_BOX_H = 150, 30

function DialogIndicatorArea:GetControllerRows(screen)
	return {
		{ {
			id = "shape", widget = self.lblShapeValue, w = VALUE_BOX_W, h = VALUE_BOX_H,
			hint = Strings().SHAPE,
			onleft = function() self:CycleShape(-1) end,
			onright = function() self:CycleShape(1) end,
			onaccept = function() self:CycleShape(1) end,
		} },
		{ {
			id = "size", widget = self.lblSizeValue, w = VALUE_BOX_W, h = VALUE_BOX_H,
			hint = Strings().SIZE,
			onleft = function() self:ChangeSize(-IndicatorArea.SIZE_STEP) end,
			onright = function() self:ChangeSize(IndicatorArea.SIZE_STEP) end,
		} },
		{ {
			id = "names", widget = self.lblNamesValue, w = VALUE_BOX_W, h = VALUE_BOX_H,
			hint = Strings().NAMES,
			onleft = function() self:ToggleNames() end,
			onright = function() self:ToggleNames() end,
			onaccept = function() self:ToggleNames() end,
		} },
		{ { id = "close", widget = self.btnClose } },
	}
end

function DialogIndicatorArea:OnControllerCancel()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
end

return DialogIndicatorArea
