--[[
Waypoint
By Nc5xb3
A model for waypoints
]]

local Waypoint = Class(function(self, name, coord, colour)
	self.name = name or "NA"
	self.coord = coord or {x = 0, y = 0, z = 0}
	self.colour = colour or {r = 1, g = 1, b = 1}
	self.hidden = false
end)

function Waypoint:SetName(name)
	self.name = name
end

function Waypoint:GetName()
	return self.name
end

function Waypoint:SetCoord(x, y, z)
	if x ~= nil then self.coord.x = x end
	if y ~= nil then self.coord.y = y end
	if z ~= nil then self.coord.z = z end
end

function Waypoint:GetCoord()
	return self.coord
end

function Waypoint:SetColour(red, green, blue)
	if red ~= nil then self.colour.r = math.max(0, math.min(1, red)) end
	if green ~= nil then self.colour.g = math.max(0, math.min(1, green)) end
	if blue ~= nil then self.colour.b = math.max(0, math.min(1, blue)) end
end

function Waypoint:GetColour()
	return self.colour
end

function Waypoint:SetHidden(hidden)
	self.hidden = hidden
end

function Waypoint:GetHidden()
	return self.hidden
end

return Waypoint