--[[
Waypoint
By Nc5xb3
A model for waypoints
]]

local Waypoint = Class(function(self, name, coord, colour)
	self.name = name or "NA"
	self.coord = coord or {}
	self.colour = colour or {}
	self.hidden = false
end)

function Waypoint:SetName(name)
	self.name = name
end

function Waypoint:GetName()
	return self.name
end

function Waypoint:SetCoord(x, y, z)
	self.coord.x = x
	self.coord.y = y
	self.coord.z = z
end

function Waypoint:GetCoord()
	return self.coord
end

function Waypoint:SetColour(red, green, blue)
	self.colour.r = red
	self.colour.g = green
	self.colour.b = blue
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