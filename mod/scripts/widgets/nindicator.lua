--[[
Indicator
By Nc5xb3
Custom indicator using DS's playerhub.lua + targetindicator.lua as reference
]]

local NPanel = require "widgets/npanel"

local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()
local Text = Compatibility:Text()

local DEFAULT_XML = "images/flag.xml"
local DEFAULT_TEX = "flag.tex"
local DEFAULT_IMG_SCALE = .2

local DEFAULT_TEXT = "empty name"
local DEFAULT_FONT_SIZE = 35
local DEFAULT_FONT_SIZE_SMALL = 25

local MARGIN_X = .3
local MARGIN_Y = .4

local SPREAD_FACTOR = 4 -- seems to affect more horizontally than vertically

-- TUNING.MIN_INDICATOR_RANGE = 30, TUNING.MAX_INDICATOR_RANGE = 50
local MIN_DIST_FADE = 10
local MIN_DIST = 30
local MAX_DIST = 50 * 5
local MAX_DIST_ALPHA = 50 * 3

local MIN_ALPHA_NEAR = .4

local ARROW_OFFSET = 50
local LABEL_OFFSET = 60
local LABEL_X_MULT = 1.5
local LABEL_X_OFFSET_MIN = 40

local TOP_EDGE_BUFFER = 60
local BOTTOM_EDGE_BUFFER = 100
local LEFT_EDGE_BUFFER = 20
local RIGHT_EDGE_BUFFER = 20

local MIN_SCALE = .5
local MIN_ALPHA = .1

local NIndicator = Class(NPanel, function(self, owner, target)
    NPanel._ctor(self, "NIndicator")
    self:SetClickable(true)
    self:SetVAnchor(ANCHOR_BOTTOM)
    self:SetHAnchor(ANCHOR_LEFT)
    
    self:Hide()
    self:SetPosition(-1000,-1000,0)

    self.owner = owner
    self.target = target

    self:SetName()
    self:SetIcon()
    self:SetColour(1,1,1)

    self.dist = self:AddChild(Text(TALKINGFONT, DEFAULT_FONT_SIZE_SMALL, ""))
    self.dist:SetPosition(0,-20,0)

    self.arrow = self:AddChild(Image("images/nuiwp.xml", "arrow.tex"))
    self.arrow:SetScale(1)
    self.arrow.inst:AddTag("NOCLICK")

    -- self.label:Hide()

    self:StartUpdating()
    self:OnUpdate()
    self:Show()
end)

function NIndicator:SetName(name, size)
    self.name = name
    if self.label ~= nil then
        self.label:Kill()
    end
    self.label = self:AddChild(Text(TALKINGFONT,
        size or DEFAULT_FONT_SIZE,
        name or DEFAULT_TEXT))
end

function NIndicator:SetTooltip(tooltip)
    if self.icon ~= nil then
        self.icon:SetTooltip(tooltip)
    end
end

function NIndicator:SetColour(r,g,b)
    if type(r) == "number" then
        self.colour = {r,g,b}
    else
        self.colour = {r[1],r[2],r[3]}
    end
end

function NIndicator:SetCallback(func)
    self.callback = func
end

function NIndicator:SetIcon(xml, tex, scale)
    if self.icon ~= nil then
        self.icon:Kill()
    end
    local t = tex or DEFAULT_TEX
    self.icon = self:AddChild(ImageButton(xml or DEFAULT_XML,t,t,t))
    self.icon:SetScale(scale or DEFAULT_IMG_SCALE)

    self.icon:SetTooltip("")
    self.icon:SetNormalScale(.9)
    self.icon:SetFocusScale(1)
    self.icon:SetImageNormalColour(.9,.9,.9,1)
    self.icon:SetImageFocusColour(1,1,1,1)
    self.icon:SetOnClick(function()
        if self.callback ~= nil then
            self.callback()
        end
    end)
end


function NIndicator:GetTarget()
    return self.target
end

function NIndicator:OnGainFocus()
    NIndicator._base.OnGainFocus(self)
    self:MoveToFront()
    -- self.label:Show()
end

function NIndicator:OnLoseFocus()
    NIndicator._base.OnLoseFocus(self)
    -- self.label:Hide()
end

function NIndicator:OnUpdate()
    local dist = 0
    if self.owner:IsValid() then
        dist = math.sqrt(self.owner:GetDistanceSqToInst(self.target))
    else
        self.owner = Compatibility:ThePlayer()
    end
    local aim = true
    local show = false
    if dist < MIN_DIST then
        -- self:Hide()
        aim = false
    end

    if self:IsVisible() then
        self.dist:SetString(math.floor(dist / TILE_SCALE) .. "m")
        if dist > MAX_DIST then
            dist = MAX_DIST
        end

        local alpha = 1

        self:SetClickable(true)
        if not self.focus then
            -- y=-0.0012x^3+0.018x^2+0.4
            if dist < MIN_DIST_FADE then
                self:SetClickable(false)
                alpha = MIN_ALPHA_NEAR+(1-MIN_ALPHA_NEAR)*(dist/MIN_DIST_FADE)^4
            else
                alpha = self:GetIndicatorAlpha(dist)
            end
        end

	    self.icon:SetImageNormalColour(self.colour[1],self.colour[2],self.colour[3],alpha)
        self.icon:SetImageFocusColour(self.colour[1],self.colour[2],self.colour[3],1)
	    self.arrow:SetTint(self.colour[1],self.colour[2],self.colour[3],alpha)
	    self.label:SetColour(self.colour[1],self.colour[2],self.colour[3],alpha)
        self.dist:SetColour(self.colour[1],self.colour[2],self.colour[3],alpha)

	    self:SetScale(Remap(dist, MIN_DIST, MAX_DIST, 1, MIN_SCALE))

	    local x, y, z = self.target.Transform:GetWorldPosition()
	    self:UpdatePosition(x, z, aim)
    end
end

function NIndicator:GetIndicatorAlpha(dist)
    if dist > MAX_DIST_ALPHA*3 then
        dist = MAX_DIST_ALPHA*3
    end
    local alpha = Remap(dist, MAX_DIST_ALPHA, MAX_DIST_ALPHA*3, 1, MIN_ALPHA)
    if dist <= MAX_DIST_ALPHA then
        alpha = 1
    end
    return alpha
end

local function GetXCoord(angle, width)
    if angle >= 90 and angle <= 180 then -- left side
        return 0
    elseif angle <= 0 and angle >= -90 then -- right side
        return width
    else -- middle somewhere
        if angle < 0 then
            angle = -angle - 90
        end
        local pctX = 1 - (angle / 90)
        return pctX * width
    end
end

local function GetYCoord(angle, height)
    if angle <= -90 and angle >= -180 then -- top side
        return height
    elseif angle >= 0 and angle <= 90 then -- bottom side
        return 0
    else -- middle somewhere
        if angle < 0 then
            angle = -angle
        end
        if angle > 90 then
            angle = angle - 90
        end
        local pctY = (angle / 90)
        return pctY * height
    end
end

function NIndicator:UpdatePosition(targX, targZ, aim)
    if aim then
        local angleToTarget = self.owner:GetAngleToPoint(targX, 0, targZ)
        local downVector = TheCamera:GetDownVec()
        local downAngle = -math.atan2(downVector.z, downVector.x) / DEGREES
        local indicatorAngle = (angleToTarget - downAngle) + 45
        while indicatorAngle > 180 do indicatorAngle = indicatorAngle - 360 end
        while indicatorAngle < -180 do indicatorAngle = indicatorAngle + 360 end

        local scale = self:GetScale()
        local w = 0
        local h = 0
        local w0, h0 = self.icon:GetSize()
        local w1, h1 = self.arrow:GetSize()
        if w0 and w1 then
            w = (w0 + w1)
        end
        if h0 and h1 then
            h = (h0 + h1)
        end

        local screenWidth, screenHeight = TheSim:GetScreenSize()

        local x = GetXCoord(indicatorAngle, screenWidth)
        local y = GetYCoord(indicatorAngle, screenHeight)

        if x <= LEFT_EDGE_BUFFER + (MARGIN_X * w * scale.x * SPREAD_FACTOR) then 
            x = LEFT_EDGE_BUFFER + (MARGIN_X * w * scale.x * SPREAD_FACTOR)
        elseif x >= screenWidth - RIGHT_EDGE_BUFFER - (MARGIN_X * w * scale.x * SPREAD_FACTOR) then
            x = screenWidth - RIGHT_EDGE_BUFFER - (MARGIN_X * w * scale.x * SPREAD_FACTOR)
        end

        if y <= BOTTOM_EDGE_BUFFER + (MARGIN_Y * h * scale.y) then 
            y = BOTTOM_EDGE_BUFFER + (MARGIN_Y * h * scale.y)
        elseif y >= screenHeight - TOP_EDGE_BUFFER - (MARGIN_Y * h * scale.y) then
            y = screenHeight - TOP_EDGE_BUFFER - (MARGIN_Y * h * scale.y)
        end

        self:SetPosition(x,y,0)
        self.x = x
        self.y = y
        self.angle = indicatorAngle
        self:PositionArrow()
        self:PositionLabel()
    else
        local x,y,z = self.target.Transform:GetWorldPosition()
        local u,v = TheSim:GetScreenPos(x,y,z)
        self:SetPosition(u,v+ARROW_OFFSET+LABEL_OFFSET,0)
        self.label:SetPosition(0,LABEL_OFFSET,0)
        self.arrow:SetPosition(0,-ARROW_OFFSET,0)
        self.arrow:SetRotation(0)
    end
end

function NIndicator:PositionArrow()
    if not self.x and self.y and self.angle then return end

    local angle = self.angle + 45
    local x = math.cos(angle*DEGREES) * ARROW_OFFSET
    local y = -math.sin(angle*DEGREES) * ARROW_OFFSET
    self.arrow:SetPosition(x,y,0)
    self.arrow:SetRotation(angle-90)
end

function NIndicator:PositionLabel()
    if not self.x and self.y and self.angle then return end

    local label_x_offset = math.max(LABEL_X_OFFSET_MIN,self.label:GetRegionSize()/2)

    local angle = self.angle + 45 - 180
    local x = math.cos(angle*DEGREES) * label_x_offset * LABEL_X_MULT
    local y = -math.sin(angle*DEGREES) * LABEL_OFFSET
    self.label:SetPosition(x,y,0)
end

return NIndicator