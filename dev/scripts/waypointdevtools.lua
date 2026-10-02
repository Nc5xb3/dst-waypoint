--[[
WaypointDevTools
TEST builds only. deploy-test.ps1 copies dev/scripts/ into the test copy of
the mod and uncomments `require("waypointdevtools")(env)` in its modmain.lua.
The repo's mod/ folder (what gets uploaded) never contains or loads this file.

Test mode: every time your character spawns (join, c_reset, character change)
you get god mode, creative mode (free crafting) and invisible mode (mobs don't
target you). c_wptestmode(false) turns it off for the session.

Console commands (press ~, and make sure the console is on LOCAL - Ctrl
toggles Local/Remote - because this is a client-side mod):

  c_wpscatter(count, radius)   random waypoints on land around you
                               (default 20 within 30 tiles)
  c_wpring(count, radius)      evenly spaced ring around you, water included
                               (default 12 at 25 tiles) - handy for indicators
  c_wpclear(all)               remove the waypoints these commands made;
                               c_wpclear(true) removes EVERY waypoint
  c_wptestmode(on)             god + creative + invisible on (default) / off
  c_wphelp()                   print this list

Waypoints made here get `test = true` (saved with them) and a "[T]" name prefix.
]]

local TEST_PREFIX = "[T] "
local LAND_ATTEMPTS = 25

local function Print(msg)
	print("[waypoint dev] " .. msg)
end

local function GetMainWp()
	local player = ThePlayer or (rawget(_G, "GetPlayer") and GetPlayer())
	local hud = player ~= nil and player.HUD or nil
	local controls = hud ~= nil and hud.controls or nil
	local wp = controls ~= nil and controls.waypoint or nil
	if wp == nil then
		Print("waypoint UI not found. Use the console in LOCAL mode (Ctrl), in a world.")
		return nil, nil
	end
	return wp, player
end

local function IsLand(x, z)
	local world = TheWorld or (rawget(_G, "GetWorld") and GetWorld())
	local map = world ~= nil and world.Map or nil
	if map == nil then
		return true
	end
	if map.IsAboveGroundAtPoint ~= nil then
		return map:IsAboveGroundAtPoint(x, 0, z)
	end
	if map.IsPassableAtPoint ~= nil then
		return map:IsPassableAtPoint(x, 0, z)
	end
	return true
end

local function AddTestWaypoint(wp, x, z, label)
	local name = TEST_PREFIX .. (label or wp:GenerateName(x, 0, z))
	local waypoint = wp:AddWaypointAt(x, 0, z, name)
	waypoint.test = true
	return waypoint
end

function c_wpscatter(count, radius)
	count = math.max(1, math.floor(tonumber(count) or 20))
	radius = math.max(1, tonumber(radius) or 30)
	local wp, player = GetMainWp()
	if wp == nil then return end
	local px, _, pz = player.Transform:GetWorldPosition()
	local maxDist = radius * TILE_SCALE

	local added = 0
	for i = 1, count do
		for attempt = 1, LAND_ATTEMPTS do
			-- uniform over the disc, at least 2 tiles from the player
			local angle = math.random() * 2 * math.pi
			local dist = math.max(2 * TILE_SCALE, maxDist * math.sqrt(math.random()))
			local x, z = px + math.cos(angle) * dist, pz + math.sin(angle) * dist
			if IsLand(x, z) then
				AddTestWaypoint(wp, x, z)
				added = added + 1
				break
			end
		end
	end
	wp:LastPage()
	Print(string.format("added %d/%d waypoints within %d tiles", added, count, radius))
end

function c_wpring(count, radius)
	count = math.max(1, math.floor(tonumber(count) or 12))
	radius = math.max(1, tonumber(radius) or 25)
	local wp, player = GetMainWp()
	if wp == nil then return end
	local px, _, pz = player.Transform:GetWorldPosition()
	local dist = radius * TILE_SCALE

	for i = 1, count do
		local angle = 2 * math.pi * (i - 1) / count
		AddTestWaypoint(wp, px + math.cos(angle) * dist, pz + math.sin(angle) * dist,
			string.format("Ring %d/%d", i, count))
	end
	wp:LastPage()
	Print(string.format("added a ring of %d waypoints at %d tiles", count, radius))
end

function c_wpclear(all)
	local wp = GetMainWp()
	if wp == nil then return end
	local removed = 0
	for i = #wp.waypoints, 1, -1 do
		local w = wp.waypoints[i]
		if all == true or (w ~= nil and w.test) then
			wp:Remove(i)
			removed = removed + 1
		end
	end
	Print(string.format("removed %d %s", removed, all == true and "waypoints (all)" or "test waypoints"))
end

-------------------------------------------------------------------------------
-- Test mode: god, creative (free crafting), invisible (debugnoattack tag).
-- These are server-side, so on a world with caves (separate server) the code
-- is sent with remote execute, like c_godmode() does; the host is an admin.
-- Written to SET the state (the game's c_godmode/c_freecrafting toggle), so
-- running it again after a respawn doesn't flip anything off.

local testModeOn = true

-- Runs on the server (master sim). God mode has to survive the game turning
-- invincibility off by itself: spawn/loading protection ends ~1.5 s after you
-- arrive with SetInvincible(false), and many player states (jumping through a
-- wormhole, teleports, ...) do the same on exit. So while test mode is on:
--   * health:SetInvincible is wrapped so it can't switch invincibility off,
--   * minhealth = 1, so even damage that ignores invincibility (drowning,
--     ForceKill, crafting health costs) can't kill you.
local TEST_MODE_SERVER_CODE = [[
local on = %s
local p = ConsoleCommandPlayer()
if p == nil then return end
local h = p.components.health
if h ~= nil then
	if h._wptest_SetInvincible == nil then
		h._wptest_SetInvincible = h.SetInvincible
		h.SetInvincible = function(self, val, ...)
			return self._wptest_SetInvincible(self, val or self._wptest_god == true, ...)
		end
	end
	h._wptest_god = on
	h._wptest_SetInvincible(h, on)
	h:SetMinHealth(on and 1 or 0)
	if on and h:IsDead() == false and h.currenthealth < 1 then h:SetVal(1) end
end
local b = p.components.builder
if b ~= nil and (b.freebuildmode == true) ~= on then
	b:GiveAllRecipes()
	p:PushEvent("techlevelchange")
end
if on then p:AddTag("debugnoattack") else p:RemoveTag("debugnoattack") end
print("[waypoint dev] test mode " .. (on and "ON" or "OFF") .. " (god, creative, invisible) for " .. tostring(p.name))
]]

local function TestModeCode(on)
	return string.format(TEST_MODE_SERVER_CODE, on and "true" or "false")
end

local function RunOnServer(code)
	if TheWorld ~= nil and TheWorld.ismastersim then
		local fn, err = loadstring(code)
		if fn == nil then
			Print("test mode code error: " .. tostring(err))
			return
		end
		fn()
	elseif TheNet ~= nil then
		TheNet:SendRemoteExecute(code, 0, 0)
	end
end

function c_wptestmode(on)
	testModeOn = on ~= false
	RunOnServer(TestModeCode(testModeOn))
end

function c_wphelp()
	Print("c_wptestmode(on=true)             god + creative + invisible on / off")
	Print("c_wpscatter(count=20, radius=30)  random waypoints on land around you")
	Print("c_wpring(count=12, radius=25)     evenly spaced ring around you")
	Print("c_wpclear()                       remove test waypoints; c_wpclear(true) removes all")
end

Print("dev tools loaded: c_wpscatter(), c_wpring(), c_wpclear(), c_wptestmode(), c_wphelp()")

-- Called from the TEST modmain with the mod environment
return function(modenv)
	if modenv == nil or modenv.AddPlayerPostInit == nil then
		Print("no mod environment; test mode must be turned on with c_wptestmode()")
		return
	end
	if rawget(_G, "TheNet") == nil or TheSim:GetGameID() ~= "DST" then
		return -- single-player DS: use the game's own console commands
	end
	modenv.AddPlayerPostInit(function(inst)
		-- Fires when this client takes control of the character
		inst:ListenForEvent("playeractivated", function()
			if testModeOn and inst == ThePlayer then
				inst:DoTaskInTime(0, function() RunOnServer(TestModeCode(true)) end)
			end
		end)
	end)
end
