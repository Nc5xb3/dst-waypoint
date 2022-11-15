--[[
NMapIcon
By Nc5xb3
]]

local NPanel = require "widgets/npanel"

local NMapIcon = Class(NPanel, function(self)
    NPanel._ctor(self, "NMapIcon")
    self:SetClickable(true)
    self:SetWorldPosition(0,0,0)
    self:SetPosition(-1000,-1000,0)
end)

function NMapIcon:SetWorldPosition(pos, y, z)
    if type(pos) == "number" then
        self.worldposition = Vector3(pos,y,z)
    else
        self.worldposition = pos
    end
end
function NMapIcon:GetWorldPosition()
    return self.worldposition
end

-- x y is Screen Position
function NMapIcon:UpdatePosition(x, y, scale)
    self:SetPosition(x,y,0)
    self:SetScale(scale)
end

function NMapIcon:OnGainFocus()
    NMapIcon._base.OnGainFocus(self)
    self:MoveToFront()
end

return NMapIcon