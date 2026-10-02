--[[
NMapIconTooltip
By Nc5xb3
Add tooltip on hover on NMapIcon as Widget tooltip does not seem to be visible
]]

local Hoverer = require "widgets/hoverer"

local NMapIconTooltip = Class(Hoverer, function(self, owner)
    Hoverer._ctor(self, owner)
end)

function NMapIconTooltip:OnUpdate()
    -- Original Hoverer:OnUpdate hides the tooltip from appearing on the map, therefore it is removed here
end

return NMapIconTooltip