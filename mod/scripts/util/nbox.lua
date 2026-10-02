--[[
NBox
By Nc5xb3
Utility for getting the corrent x, y values, and other measurements.
Since the game y axis is measures down-up, this converts it up-down.
]]

local NBox = Class(function(self,w,h)
	self:SetSize(w or 0,h or 0)
end)

function NBox:SetSize(w,h)
    if type(w) == "number" then
		self.size={w,h}
    else
		self.size={w[1],w[2]}
    end
end

function NBox:GetSize()
    local w, h = self.size
    return w, h
end

function NBox:W()
	return self.size[1]
end

function NBox:H()
	return self.size[2]
end

function NBox:X(x)
	return -self.size[1]/2+x
end

function NBox:Y(y)
	return self.size[2]/2-y
end

function NBox:GridW(mc)
	return self.size[1]/mc
end

function NBox:GridX(c,mc)
	return self:X(0)+self:GridW(mc)*(c-.5)
end

function NBox:GridH(mr)
	return self.size[2]/mr
end

function NBox:GridY(r,mr)
	return self:Y(0)-self:GridH(mr)*(r-.5)
end

return NBox