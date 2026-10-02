--[[
WaypointControllerScreen
Controller navigation for the waypoint window and its dialogs.

The waypoint window (MainWp) lives in the HUD, not in a Screen, so the game's
own focus system can't reach it. While the window is open with a controller,
this invisible screen sits on top of the HUD and:
  * takes every controller input (so the player doesn't move / open crafting),
  * keeps a "cursor" on one item of the topmost waypoint panel (main window,
    edit dialog, configurations, ...), drawn as a gold outline + tooltip,
  * moves the cursor with the d-pad / left stick and runs the item's action.

Panels describe themselves with GetControllerRows(screen): a list of rows,
each a list of nodes:
  {
    id           = "unique-id",       -- keeps the cursor on the same item after refreshes
    widget       = w,                 -- the item (must be visible to be selectable)
    box          = w2,                -- optional: outline this widget instead
    w, h         = 100, 30,           -- optional: outline size (otherwise measured)
    focuswidget  = w3,                -- optional: gets OnGainFocus/OnLoseFocus (default: widget)
    hint         = "text",            -- optional tooltip (default: the widget's tooltip)
    onaccept     = fn,                -- A (default: the widget's onclick)
    acceptLabel  = "Travel",
    onleft/onright = fn, changeLabel = "Change",  -- left/right adjust instead of moving
    onx/xLabel, ony/yLabel,           -- X / Y shortcuts
  }
onaccept may return a "capture" table to take over the d-pad until A/B:
  { ondir = fn(dx, dy), onshoulder = fn(d), help = { {control, label}, ... }, hint = "text" }
Optional panel methods: OnControllerCancel(screen), OnControllerPage(dir),
GetControllerDefaultFocus() -> id, controllerBackLabel.
]]

local Screen = require "widgets/screen"
local Widget = require "widgets/widget"

local Compatibility = require "util/compatibility"
local Image = Compatibility:Image()
local Text = Compatibility:Text()

local OUTLINE_COLOUR = {1, .82, .3, 1}
local OUTLINE_CAPTURE_COLOUR = {.45, .9, 1, 1}
local FILL_ALPHA = .12
local OUTLINE_THICKNESS = 2
local OUTLINE_PADDING = 5
local TOOLTIP_FONT_SIZE = 20
local TOOLTIP_PADDING = 6
local DEFAULT_NODE_SIZE = 40

local function C(name)
	return rawget(_G, name)
end

local function Strings()
	return STRINGS.WAYPOINT.UI.CONTROLLER
end

local function SafeCall(fn, ...)
	if fn == nil then return nil end
	local ok, result = pcall(fn, ...)
	if not ok then
		print("[waypoint] controller action failed: " .. tostring(result))
		return nil
	end
	return result
end

local function IsAlive(widget)
	return widget ~= nil and widget.inst ~= nil and widget.inst:IsValid()
end

-- Position of a widget in its ancestor panel's coordinates (panels don't scale
-- their children, so summing positions is enough)
local function PositionIn(widget, panel)
	local x, y = 0, 0
	local w = widget
	while w ~= nil and w ~= panel do
		local p = w:GetPosition()
		x = x + p.x
		y = y + p.y
		w = w.parent
	end
	if w ~= panel then
		return nil
	end
	return x, y
end

-- The widget's own scale (Widget:GetScale in DST multiplies in every parent)
local function ScaleX(widget)
	if widget.inst ~= nil and widget.inst.UITransform ~= nil then
		local sx, sy = widget.inst.UITransform:GetScale()
		if sx ~= nil then
			return sx, sy or sx
		end
	end
	local s = widget:GetScale()
	return (s and s.x) or 1, (s and s.y) or 1
end

local function NodeSize(node)
	if node.w ~= nil and node.h ~= nil then
		return node.w, node.h
	end
	local wd = node.box or node.widget
	if wd.image ~= nil and wd.image.GetSize ~= nil then
		local ok, w, h = pcall(wd.image.GetSize, wd.image)
		if ok and w ~= nil and h ~= nil then
			local isx, isy = ScaleX(wd.image)
			local wsx, wsy = ScaleX(wd)
			return w * isx * wsx, h * isy * wsy
		end
	end
	if wd.inst ~= nil and type(wd.inst.size) == "table" and wd.inst.size[1] ~= nil and wd.inst.size[1] > 0 then
		return wd.inst.size[1], wd.inst.size[2]
	end
	if wd.GetRegionSize ~= nil then
		local ok, w, h = pcall(wd.GetRegionSize, wd)
		if ok and w ~= nil and h ~= nil and w > 0 then
			return w, h
		end
	end
	return DEFAULT_NODE_SIZE, DEFAULT_NODE_SIZE
end

local function NodeHint(node)
	if node.hint ~= nil then
		return node.hint ~= "" and node.hint or nil
	end
	local wd = node.widget
	local tip = nil
	if wd.GetTooltip ~= nil then
		local ok, t = pcall(wd.GetTooltip, wd)
		if ok then tip = t end
	end
	if tip == nil then
		tip = wd.tooltip
	end
	if type(tip) == "string" and tip ~= "" then
		return tip
	end
	return nil
end

local WaypointControllerScreen = Class(Screen, function(self, mainwp)
	Screen._ctor(self, "WaypointControllerScreen")
	self.mainwp = mainwp
	self.cursor = {}      -- [panel] = { id = , row = , col = }
	self.rows = {}
	self.panel = nil
	self.focused = nil    -- widget that currently has our fake focus
	self.capture = nil
	self.pressed = {}     -- controls whose "down" we received (we act on release)
	self.closed = false
	self:StartUpdating()
end)

-------------------------------------------------------------------------------
-- Layout

function WaypointControllerScreen:GetActivePanel()
	local wp = self.mainwp
	if not IsAlive(wp) then
		return nil
	end
	if wp.GetControllerPanel ~= nil then
		return wp:GetControllerPanel()
	end
	return wp
end

function WaypointControllerScreen:BuildRows(panel)
	local rows = {}
	if panel == nil or panel.GetControllerRows == nil then
		return rows
	end
	local raw = SafeCall(panel.GetControllerRows, panel, self) or {}
	for _, row in ipairs(raw) do
		local kept = {}
		for _, node in ipairs(row) do
			if node ~= nil and IsAlive(node.widget) and node.widget:IsVisible() then
				table.insert(kept, node)
			end
		end
		if #kept > 0 then
			table.insert(rows, kept)
		end
	end
	return rows
end

function WaypointControllerScreen:FindNode(id)
	if id == nil then return nil end
	for r, row in ipairs(self.rows) do
		for c, node in ipairs(row) do
			if node.id == id then
				return r, c
			end
		end
	end
	return nil
end

function WaypointControllerScreen:CurrentNode()
	local cur = self.panel and self.cursor[self.panel]
	if cur == nil then return nil end
	local row = self.rows[cur.row]
	return row and row[cur.col]
end

-- Rebuilds the item list of the topmost panel and keeps the cursor on the same
-- item (by id), or on the nearest position if that item is gone.
function WaypointControllerScreen:Refresh()
	local panel = self:GetActivePanel()
	if panel ~= self.panel then
		self:ClearHighlight()
		self.capture = nil
		self.panel = panel
	end
	self.rows = self:BuildRows(panel)
	if panel == nil then
		return
	end

	local cur = self.cursor[panel]
	if cur ~= nil and cur.pendingId ~= nil then
		local r, c = self:FindNode(cur.pendingId)
		if r ~= nil then
			cur.row, cur.col, cur.id = r, c, cur.pendingId
		end
		cur.pendingId = nil
	end
	if cur ~= nil and cur.id ~= nil then
		local r, c = self:FindNode(cur.id)
		if r ~= nil then
			cur.row, cur.col = r, c
		end
	end
	if cur == nil then
		cur = {}
		self.cursor[panel] = cur
		local r, c = nil, nil
		if panel.GetControllerDefaultFocus ~= nil then
			r, c = self:FindNode(SafeCall(panel.GetControllerDefaultFocus, panel))
		end
		cur.row, cur.col = r or 1, c or 1
	end

	if #self.rows == 0 then
		cur.row, cur.col = 1, 1
		self:UpdateHighlight(nil)
		return
	end
	cur.row = math.max(1, math.min(cur.row or 1, #self.rows))
	cur.col = math.max(1, math.min(cur.col or 1, #self.rows[cur.row]))
	local node = self.rows[cur.row][cur.col]
	cur.id = node.id
	self:UpdateHighlight(node)
end

-- Ask the next refresh to put the cursor on this item (e.g. a new waypoint)
function WaypointControllerScreen:FocusId(id, panel)
	panel = panel or self:GetActivePanel()
	if panel == nil then return end
	self.cursor[panel] = self.cursor[panel] or {}
	self.cursor[panel].pendingId = id
end

-------------------------------------------------------------------------------
-- Highlight (outline + tooltip), parented to the active panel

function WaypointControllerScreen:CreateHighlight(panel)
	local root = panel:AddChild(Widget("WaypointControllerHighlight"))
	root:SetClickable(false)

	local function Bar()
		local bar = root:AddChild(Image("images/white.xml", "white.tex"))
		bar:SetClickable(false)
		return bar
	end
	root.fill = Bar()
	root.top, root.bottom, root.left, root.right = Bar(), Bar(), Bar(), Bar()

	root.tipBack = Bar()
	root.tipBack:SetTint(0, 0, 0, .7)
	root.tip = root:AddChild(Text(TALKINGFONT, TOOLTIP_FONT_SIZE))
	root.tip:SetClickable(false)
	return root
end

function WaypointControllerScreen:ClearHighlight()
	if self.focused ~= nil then
		local old = self.focused
		self.focused = nil
		if IsAlive(old) and old.OnLoseFocus ~= nil then
			SafeCall(old.OnLoseFocus, old)
		end
	end
	if self.highlight ~= nil then
		if IsAlive(self.highlight) then
			self.highlight:Kill()
		end
		self.highlight = nil
	end
end

function WaypointControllerScreen:SetFakeFocus(widget)
	if widget == self.focused then
		return
	end
	local old = self.focused
	self.focused = widget
	if IsAlive(old) and old.OnLoseFocus ~= nil then
		SafeCall(old.OnLoseFocus, old)
	end
	if IsAlive(widget) then
		-- Buttons play the game's hover sound themselves in OnGainFocus
		if widget.SetOnClick == nil then
			self:PlayMoveSound()
		end
		if widget.OnGainFocus ~= nil then
			SafeCall(widget.OnGainFocus, widget)
		end
	end
end

function WaypointControllerScreen:UpdateHighlight(node)
	if node == nil then
		self:SetFakeFocus(nil)
		if self.highlight ~= nil and IsAlive(self.highlight) then
			self.highlight:Hide()
		end
		return
	end
	self:SetFakeFocus(node.focuswidget or node.widget)

	local panel = self.panel
	if self.highlight == nil or not IsAlive(self.highlight) or self.highlight.parent ~= panel then
		if self.highlight ~= nil and IsAlive(self.highlight) then
			self.highlight:Kill()
		end
		self.highlight = self:CreateHighlight(panel)
	end
	local hl = self.highlight
	hl:MoveToFront()

	local x, y = PositionIn(node.box or node.widget, panel)
	if x == nil then
		hl:Hide()
		return
	end
	hl:Show()

	local w, h = NodeSize(node)
	w = w + OUTLINE_PADDING * 2
	h = h + OUTLINE_PADDING * 2
	local t = OUTLINE_THICKNESS
	local col = self.capture ~= nil and OUTLINE_CAPTURE_COLOUR or OUTLINE_COLOUR

	hl:SetPosition(x, y, 0)
	hl.fill:SetSize(w, h)
	hl.fill:SetTint(col[1], col[2], col[3], FILL_ALPHA)
	hl.top:SetSize(w + t, t)
	hl.top:SetPosition(0, h / 2, 0)
	hl.bottom:SetSize(w + t, t)
	hl.bottom:SetPosition(0, -h / 2, 0)
	hl.left:SetSize(t, h + t)
	hl.left:SetPosition(-w / 2, 0, 0)
	hl.right:SetSize(t, h + t)
	hl.right:SetPosition(w / 2, 0, 0)
	for _, bar in ipairs({hl.top, hl.bottom, hl.left, hl.right}) do
		bar:SetTint(col[1], col[2], col[3], col[4])
	end

	local hint = (self.capture ~= nil and self.capture.hint) or NodeHint(node)
	if hint ~= nil then
		hl.tip:SetString(hint)
		local tw, th = TOOLTIP_FONT_SIZE * 4, TOOLTIP_FONT_SIZE
		local ok, rw, rh = pcall(hl.tip.GetRegionSize, hl.tip)
		if ok and rw ~= nil and rh ~= nil then
			tw, th = rw, rh
		end
		local ty = h / 2 + th / 2 + TOOLTIP_PADDING + 2
		hl.tip:SetPosition(0, ty, 0)
		hl.tipBack:SetSize(tw + TOOLTIP_PADDING * 2, th + TOOLTIP_PADDING)
		hl.tipBack:SetPosition(0, ty, 0)
		hl.tip:Show()
		hl.tipBack:Show()
	else
		hl.tip:Hide()
		hl.tipBack:Hide()
	end
end

-------------------------------------------------------------------------------
-- Navigation

function WaypointControllerScreen:MoveVertical(dir)
	local cur = self.cursor[self.panel]
	if cur == nil or #self.rows == 0 then return end
	local fromNode = self:CurrentNode()
	local fromX = 0
	if fromNode ~= nil then
		fromX = PositionIn(fromNode.box or fromNode.widget, self.panel) or 0
	end
	local r = cur.row + dir
	if r < 1 then r = #self.rows end
	if r > #self.rows then r = 1 end
	-- pick the item in the new row closest horizontally
	local best, bestDist = 1, nil
	for c, node in ipairs(self.rows[r]) do
		local nx = PositionIn(node.box or node.widget, self.panel) or 0
		local d = math.abs(nx - fromX)
		if bestDist == nil or d < bestDist then
			best, bestDist = c, d
		end
	end
	cur.row, cur.col, cur.id = r, best, self.rows[r][best].id
end

function WaypointControllerScreen:MoveHorizontal(dir)
	local node = self:CurrentNode()
	if node == nil then return end
	local adjust = dir < 0 and node.onleft or node.onright
	if adjust ~= nil then
		SafeCall(adjust)
		self:PlayClickSound()
		return
	end
	local cur = self.cursor[self.panel]
	local row = self.rows[cur.row]
	local c = cur.col + dir
	if c >= 1 and c <= #row then
		cur.col, cur.id = c, row[c].id
	end
end

function WaypointControllerScreen:PlayMoveSound()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
end

function WaypointControllerScreen:PlayClickSound()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
end

function WaypointControllerScreen:Accept()
	local node = self:CurrentNode()
	if node == nil then return end
	local action = node.onaccept
	if action == nil then
		local wd = node.focuswidget or node.widget
		if wd.onclick ~= nil and (wd.IsEnabled == nil or wd:IsEnabled()) then
			action = wd.onclick
		end
	end
	if action == nil then return end
	self:PlayClickSound()
	local result = SafeCall(action)
	if type(result) == "table" and (result.ondir ~= nil or result.onshoulder ~= nil) then
		self.capture = result
	end
end

function WaypointControllerScreen:Cancel()
	if self.capture ~= nil then
		self.capture = nil
		self:PlayClickSound()
		return
	end
	local panel = self.panel
	if panel ~= nil and panel ~= self.mainwp and panel.OnControllerCancel ~= nil then
		self:PlayClickSound()
		SafeCall(panel.OnControllerCancel, panel, self)
		return
	end
	self:Close()
end

function WaypointControllerScreen:Page(dir)
	local panel = self.panel
	if panel ~= nil and panel.OnControllerPage ~= nil then
		SafeCall(panel.OnControllerPage, panel, dir)
	end
end

-------------------------------------------------------------------------------
-- Input

local DIRECTIONS = {
	CONTROL_FOCUS_UP = {0, 1},
	CONTROL_FOCUS_DOWN = {0, -1},
	CONTROL_FOCUS_LEFT = {-1, 0},
	CONTROL_FOCUS_RIGHT = {1, 0},
}

-- Directions come from OnFocusMove (DST) or CONTROL_FOCUS_* controls (DS);
-- a repeat of the same direction in the same frame is ignored just in case.
function WaypointControllerScreen:HandleDirection(dx, dy)
	local now = GetTime()
	local last = self.lastDirection
	if last ~= nil and last.t == now and last.dx == dx and last.dy == dy then
		return
	end
	self.lastDirection = { t = now, dx = dx, dy = dy }

	if self.capture ~= nil then
		if self.capture.ondir ~= nil then SafeCall(self.capture.ondir, dx, dy) end
	elseif dy ~= 0 then
		self:MoveVertical(-dy) -- rows are listed top to bottom
	else
		self:MoveHorizontal(dx)
	end
	self:Refresh()
end

local FOCUS_MOVES = {
	MOVE_UP = {0, 1},
	MOVE_DOWN = {0, -1},
	MOVE_LEFT = {-1, 0},
	MOVE_RIGHT = {1, 0},
}

function WaypointControllerScreen:OnFocusMove(dir, down)
	if self.closed then
		return true
	end
	if down then
		for name, d in pairs(FOCUS_MOVES) do
			if dir == C(name) then
				self:HandleDirection(d[1], d[2])
				break
			end
		end
	end
	return true
end

function WaypointControllerScreen:OnControl(control, down)
	if self.closed then
		return true
	end
	if not IsAlive(self.mainwp) then
		self:Close()
		return true
	end

	-- Directions and paging act on press (the game repeats focus moves while held)
	if down then
		for name, dir in pairs(DIRECTIONS) do
			if control == C(name) then
				-- DST's front end turns the d-pad/stick into OnFocusMove calls
				-- (with repeat while held), so only use these as a fallback.
				if not Compatibility:IsDST() then
					self:HandleDirection(dir[1], dir[2])
				end
				return true
			end
		end
		if control == C("CONTROL_SCROLLBACK") or control == C("CONTROL_SCROLLFWD") then
			local d = control == C("CONTROL_SCROLLBACK") and -1 or 1
			if self.capture ~= nil then
				if self.capture.onshoulder ~= nil then SafeCall(self.capture.onshoulder, d) end
			else
				self:Page(d)
			end
			self:Refresh()
			return true
		end
		self.pressed[control] = true
		return true
	end

	-- Buttons act on release, and only if we saw the press (ignores the release
	-- of the button that opened this screen or closed a popup on top of it)
	if not self.pressed[control] then
		return true
	end
	self.pressed[control] = nil

	if control == C("CONTROL_ACCEPT") then
		if self.capture ~= nil then
			self.capture = nil
			self:PlayClickSound()
		else
			self:Accept()
		end
	elseif control == C("CONTROL_CANCEL") then
		self:Cancel()
	elseif control == C("CONTROL_MENU_MISC_1") then
		local node = self:CurrentNode()
		if self.capture == nil and node ~= nil and node.onx ~= nil then
			self:PlayClickSound()
			SafeCall(node.onx)
		end
	elseif control == C("CONTROL_MENU_MISC_2") then
		local node = self:CurrentNode()
		if self.capture == nil and node ~= nil and node.ony ~= nil then
			self:PlayClickSound()
			SafeCall(node.ony)
		end
	end
	if not self.closed then
		self:Refresh()
	end
	return true
end

function WaypointControllerScreen:GetHelpText()
	local input = TheInput
	local cid = input:GetControllerID()
	local strs = Strings()
	local parts = {}
	local function add(controlName, label)
		local control = C(controlName)
		if control ~= nil and label ~= nil then
			table.insert(parts, input:GetLocalizedControl(cid, control) .. " " .. label)
		end
	end

	if self.capture ~= nil then
		for _, h in ipairs(self.capture.help or {}) do
			add(h[1], h[2])
		end
		add("CONTROL_ACCEPT", strs.DONE)
		return table.concat(parts, "  ")
	end

	local node = self:CurrentNode()
	if node ~= nil then
		local wd = node.focuswidget or node.widget
		if node.onaccept ~= nil or wd.onclick ~= nil then
			add("CONTROL_ACCEPT", node.acceptLabel or strs.SELECT)
		end
		if node.onleft ~= nil or node.onright ~= nil then
			add("CONTROL_FOCUS_RIGHT", node.changeLabel or strs.CHANGE)
		end
		if node.onx ~= nil then add("CONTROL_MENU_MISC_1", node.xLabel) end
		if node.ony ~= nil then add("CONTROL_MENU_MISC_2", node.yLabel) end
	end
	if self.panel ~= nil and self.panel.OnControllerPage ~= nil then
		local back, fwd = C("CONTROL_SCROLLBACK"), C("CONTROL_SCROLLFWD")
		if back ~= nil and fwd ~= nil then
			table.insert(parts, input:GetLocalizedControl(cid, back) .. "/" ..
				input:GetLocalizedControl(cid, fwd) .. " " .. strs.PAGE)
		end
	end
	local backLabel = (self.panel ~= nil and self.panel.controllerBackLabel) or
		(self.panel == self.mainwp and strs.CLOSE or strs.BACK)
	add("CONTROL_CANCEL", backLabel)
	return table.concat(parts, "  ")
end

-------------------------------------------------------------------------------
-- Lifecycle

function WaypointControllerScreen:OnBecomeActive()
	WaypointControllerScreen._base.OnBecomeActive(self)
	self.pressed = {}
	self:Refresh()
end

function WaypointControllerScreen:OnUpdate(dt)
	if self.closed then
		return
	end
	-- Window closed some other way (mouse, HUD rebuilt, ...)
	if not IsAlive(self.mainwp) or not self.mainwp.shown then
		self:Close()
		return
	end
	self:Refresh()
end

function WaypointControllerScreen:Close()
	if self.closed then
		return
	end
	self.closed = true
	self:StopUpdating()
	self:ClearHighlight()
	local wp = self.mainwp
	if IsAlive(wp) then
		if wp.controllerScreen == self then
			wp.controllerScreen = nil
		end
		if wp.OnControllerScreenClosed ~= nil then
			SafeCall(wp.OnControllerScreenClosed, wp)
		end
	end
	-- Only pop if we're still on the stack
	local stack = TheFrontEnd.screenstack
	local onStack = stack == nil
	for _, screen in ipairs(stack or {}) do
		if screen == self then
			onStack = true
			break
		end
	end
	if onStack then
		TheFrontEnd:PopScreen(self)
	end
end

return WaypointControllerScreen
