--[[
IndicatorArea
Shared settings + geometry for where off-screen waypoint indicators sit.
Used by NIndicator (placement) and DialogIndicatorArea (preview outline).

All coordinates are screen pixels with the origin at the bottom-left, the same
space NIndicator positions itself in.
]]

local IndicatorArea = {
	SHAPES = { "rectangle", "ellipse", "circle" },
	MIN_SIZE = 30,
	MAX_SIZE = 100,
	SIZE_STEP = 10,
	DEFAULT_SHAPE = "rectangle",
	DEFAULT_SIZE = 50, -- roughly where indicators sat before this was configurable

	-- Distance from the screen edges to the outline at 100%. Includes room for
	-- the indicator's icon/arrow so they stay on screen, and keeps clear of the
	-- HUD at the top/bottom. The outline is where indicator flag *centres* go.
	TOP_EDGE_BUFFER = 110,
	BOTTOM_EDGE_BUFFER = 150,
	LEFT_EDGE_BUFFER = 70,
	RIGHT_EDGE_BUFFER = 70,

	-- Show indicator names only while hovering the flag
	namesOnHover = false,
}
IndicatorArea.shape = IndicatorArea.DEFAULT_SHAPE
IndicatorArea.size = IndicatorArea.DEFAULT_SIZE -- percent of the largest area that fits the screen

function IndicatorArea:IsValidShape(shape)
	for _, s in ipairs(self.SHAPES) do
		if s == shape then
			return true
		end
	end
	return false
end

function IndicatorArea:ClampSize(size)
	if type(size) ~= "number" then
		return nil
	end
	local step = self.SIZE_STEP
	size = math.floor(size / step + .5) * step
	return math.max(self.MIN_SIZE, math.min(self.MAX_SIZE, size))
end

function IndicatorArea:Set(shape, size)
	if self:IsValidShape(shape) then
		self.shape = shape
	end
	local clamped = self:ClampSize(size)
	if clamped ~= nil then
		self.size = clamped
	end
end

-- Centre and half-extents of the area. Indicators and the preview both use
-- this, so the preview outline is exactly where indicators sit.
function IndicatorArea:GetBox(screenW, screenH)
	local left = self.LEFT_EDGE_BUFFER
	local right = screenW - self.RIGHT_EDGE_BUFFER
	local bottom = self.BOTTOM_EDGE_BUFFER
	local top = screenH - self.TOP_EDGE_BUFFER
	local cx, cy = (left + right) / 2, (bottom + top) / 2
	local s = self.size / 100
	local hx = math.max(1, (right - left) / 2 * s)
	local hy = math.max(1, (top - bottom) / 2 * s)
	if self.shape == "circle" then
		local r = math.min(hx, hy)
		hx, hy = r, r
	end
	return cx, cy, hx, hy
end

-- Point on the shape's outline in direction (dx, dy) from its centre
function IndicatorArea:PointAt(dx, dy, cx, cy, hx, hy)
	local len = math.sqrt(dx * dx + dy * dy)
	if len < 1e-6 then
		return cx, cy
	end
	dx, dy = dx / len, dy / len

	local t
	if self.shape == "rectangle" then
		local tx = math.abs(dx) > 1e-6 and hx / math.abs(dx) or math.huge
		local ty = math.abs(dy) > 1e-6 and hy / math.abs(dy) or math.huge
		t = math.min(tx, ty)
	else -- ellipse / circle (circle has hx == hy)
		t = 1 / math.sqrt((dx / hx) ^ 2 + (dy / hy) ^ 2)
	end
	return cx + dx * t, cy + dy * t
end

-- Evenly spaced points around the outline (for the preview)
function IndicatorArea:SampleOutline(cx, cy, hx, hy, count)
	local points = {}
	if self.shape == "rectangle" then
		local perimeter = 4 * (hx + hy)
		for i = 0, count - 1 do
			local d = perimeter * i / count
			local x, y
			if d < 2 * hx then
				x, y = cx - hx + d, cy + hy                         -- top
			elseif d < 2 * hx + 2 * hy then
				x, y = cx + hx, cy + hy - (d - 2 * hx)              -- right
			elseif d < 4 * hx + 2 * hy then
				x, y = cx + hx - (d - 2 * hx - 2 * hy), cy - hy     -- bottom
			else
				x, y = cx - hx, cy - hy + (d - 4 * hx - 2 * hy)     -- left
			end
			table.insert(points, { x, y })
		end
	else
		for i = 0, count - 1 do
			local a = 2 * math.pi * i / count
			table.insert(points, { cx + math.cos(a) * hx, cy + math.sin(a) * hy })
		end
	end
	return points
end

return IndicatorArea
