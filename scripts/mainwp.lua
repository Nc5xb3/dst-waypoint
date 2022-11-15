--[[
MainWp
By Nc5xb3
]]

local Styler = require "styler"
local NBox = require "util/nbox"

local NPanel = require "widgets/npanel"
local NInput = require "widgets/ninput"
local NMapIconTemplate = require "widgets/nmapicontemplate"

-- CLASSES
local Waypoint = require "waypoint"

-- DIALOG
local DialogEdit = require "dialogedit"
local DialogMp = require "dialogmp"

-- OTHER
local PersistentData = require "persistentdata"
local AdjectivesUtility = require "util/adjectivesutility"

-- WIDGETS
local Compatibility = require "util/compatibility"
local ImageButton = Compatibility:ImageButton()
local Image = Compatibility:Image()
local Text = Compatibility:Text()

-- CONSTANTS
local DEFAULT_LIST_ITEM_HEIGHT = 45
local TOGGLE_ALPHA_DISABLED = .4
local TOGGLE_ALPHA_HOVER = .7
local DIRECTION_LINE_MAX_RANGE = 5

local MainWp = Class(NPanel, function(self, w, h, skin, showCoordinates, disableAutoTravel, colourVariety) 
	NPanel._ctor(self, "Waypoint")
	self.w = w or 360
	self.h = h or 480
	self.skin = skin or 1
	self.showCoordinates = showCoordinates or false
	self.disableAutoTravel = disableAutoTravel or false
	self.colourVariety = colourVariety or 8

	self.editMode = false
	self.markerMode = false

	self.listWaypoint = {}
	self.pageIndex = 1
	self.pageSize = 0

	self:InitialisePersistentData()
	self:InitialiseComponents(self.w, self.h)
	Styler(self.skin):ApplyStyle(self)
	self:LoadData()
end)

function MainWp:InitialisePersistentData()
	local oldId = Compatibility:TheWorld().meta.seed

	-- generate new id
	local newId = nil
	if Compatibility:TheWorld().meta.session_identifier ~= nil then
		newId = Compatibility:TheWorld().meta.session_identifier
	else
		newId = oldId
	end
	-- -- I believe we don't need level_id for this
	-- if Compatibility:TheWorld().meta.level_id ~= nil then
	-- 	if newId == nil then
	-- 		newId = Compatibility:TheWorld().meta.level_id
	-- 	else
	-- 		newId = newId .. '_' .. Compatibility:TheWorld().meta.level_id
	-- 	end
	-- end

	-- append suffix for cave
	if Compatibility:TheWorld():HasTag("cave") then
		oldId = oldId .. "_C"
		newId = newId .. "_C"
	end
	
	self.uwidOld = "waypoint_" .. oldId
	self.uwid = "waypoint_" .. newId
	print("[waypoint] uwid: " .. self.uwid)

	self.dataContainer = PersistentData("waypoint")
	self.dataContainer:Load()
end

function MainWp:InitialiseComponents(w, h)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	-- self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self:SetPosition(-310,20)
	self:SetSize(w,h)

	self:AddClass("Frame")

	local box = NBox(self:GetSize())

	local maxRows = math.floor(box:H()/DEFAULT_LIST_ITEM_HEIGHT)
	local maxCols = 10
	self.pageSize = maxRows - 2

	local labelTitle = self:AddChild(Text(TALKINGFONT,28))
	labelTitle:SetPosition(box:GridX(4,maxCols),box:GridY(1,maxRows),0) -- X Center; 1-4-7|8,9,10
	labelTitle:SetString(STRINGS.WAYPOINT.UI.MENU.TITLE)

	self.btnEdit = self:AddChild(ImageButton("images/nuiwp.xml","edit.tex","edit.tex","edit.tex"))
	self.btnEdit:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.TOGGLE_EDITMODE)
	self.btnEdit:SetPosition(box:GridX(8,maxCols),box:GridY(1,maxRows),0)
	self.btnEdit:SetNormalScale(.5)
	self.btnEdit:SetFocusScale(.57)
	self.btnEdit:SetImageNormalColour(.9,.9,.9,TOGGLE_ALPHA_DISABLED)
	self.btnEdit:SetImageFocusColour(1,1,1,TOGGLE_ALPHA_HOVER)
	self.btnEdit:SetOnClick(function() self:ToggleEditMode() end)

	self.btnIndicators = self:AddChild(ImageButton("images/nuiwp.xml","marker.tex","marker.tex","marker.tex"))
	self.btnIndicators:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.TOGGLE_INDICATORS)
	self.btnIndicators:SetPosition(box:GridX(9,maxCols),box:GridY(1,maxRows),0)
	self.btnIndicators:SetNormalScale(.5)
	self.btnIndicators:SetFocusScale(.57)
	self.btnIndicators:SetImageNormalColour(.9,.9,.9,TOGGLE_ALPHA_DISABLED)
	self.btnIndicators:SetImageFocusColour(1,1,1,TOGGLE_ALPHA_HOVER)
	self.btnIndicators:SetOnClick(function() self:ToggleMarkerMode() end)

	self.btnAdd = self:AddChild(ImageButton("images/nuiwp.xml","flag.tex","flag.tex","flag.tex"))
	self.btnAdd:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.ADD)
	self.btnAdd:SetPosition(box:GridX(10,maxCols),box:GridY(1,maxRows),0)
	self.btnAdd:SetNormalScale(.6)
	self.btnAdd:SetFocusScale(.68)
	self.btnAdd:SetImageNormalColour(.9,.9,.9,1)
	self.btnAdd:SetImageFocusColour(1,1,1,1)
	self.btnAdd:SetOnClick(function() self:Add() end)

	-- LIST OF WAYPOINTS
	for i=1,self.pageSize do
		self.listWaypoint[i] = self:AddChild(NPanel("WaypointItem"))
		local li = self.listWaypoint[i]
		li:AddClass("ListItem")
		li:SetPosition(0,box:GridY(1+i,maxRows))
		li:SetSize(box:W()-20,box:GridH(maxRows)-5)

		local liBox = NBox(li:GetSize())

		li.lblName = li:AddChild(NInput("WaypointName"))
		li.lblName:SetPosition(liBox:GridX(4,maxCols),0) -- X Center; 1-4-7
		li.lblName:SetSize(liBox:GridW(10)*7-10,liBox:H()-10)

		-- coordinate x
		li.lblX = li:AddChild(Text(NUMBERFONT,16))
		li.lblX:SetPosition(liBox:GridX(8,maxCols),liBox:GridY(1,2))
		li.lblX:SetString("")

		-- coordinate y
		li.lblZ = li:AddChild(Text(NUMBERFONT,16))
		li.lblZ:SetPosition(liBox:GridX(8,maxCols),liBox:GridY(2,2))
		li.lblZ:SetString("")

		li.lblArrow = li:AddChild(Image("images/nuiwp.xml", "direction.tex"))
	    li.lblArrow.inst:AddTag("NOCLICK")
		li.lblArrow:SetPosition(liBox:GridX(9,maxCols),0,0)
		li.lblArrow:SetTint(1,1,1,.4)

		-- distance
		li.lblDistance = li:AddChild(Text(NUMBERFONT,20))
		li.lblDistance:SetPosition(liBox:GridX(9,maxCols),0,0)

		-- travel flag
		li.btnNavigate = li:AddChild(ImageButton("images/nuiwp.xml","flag.tex","flag.tex","flag.tex"))
		if not self.disableAutoTravel then
			li.btnNavigate:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.TRAVEL)
		end
		li.btnNavigate:SetPosition(liBox:GridX(10,maxCols),liBox:GridY(1,1))
		li.btnNavigate:SetNormalScale(.5)
		li.btnNavigate:SetFocusScale(.57)
		li.btnNavigate:SetImageNormalColour(.9,.9,.9,1)
		li.btnNavigate:SetImageFocusColour(1,1,1,1)

		-- Side bar

		li.btnUp = li:AddChild(ImageButton("images/nuiwp.xml","up.tex","up.tex","up.tex"))
		li.btnUp:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.MOVE_UP)
		li.btnUp:SetPosition(liBox:GridX(8,maxCols),liBox:GridY(1,2))
		li.btnUp:SetNormalScale(.5)
		li.btnUp:SetFocusScale(.57)
		li.btnUp:SetImageNormalColour(.9,.9,.9,1)
		li.btnUp:SetImageFocusColour(1,1,1,1)

		li.btnDown = li:AddChild(ImageButton("images/nuiwp.xml","down.tex","down.tex","down.tex"))
		li.btnDown:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.MOVE_DOWN)
		li.btnDown:SetPosition(liBox:GridX(8,maxCols),liBox:GridY(2,2))
		li.btnDown:SetNormalScale(.5)
		li.btnDown:SetFocusScale(.57)
		li.btnDown:SetImageNormalColour(.9,.9,.9,1)
		li.btnDown:SetImageFocusColour(1,1,1,1)

		li.btnHidden = li:AddChild(ImageButton("images/nuiwp.xml","markeron.tex","markeron.tex","markeron.tex"))
		li.btnHidden:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.TOGGLE_VISIBILITY)
		li.btnHidden:SetPosition(liBox:GridX(9,maxCols),liBox:GridY(1,1))
		li.btnHidden:SetNormalScale(.5)
		li.btnHidden:SetFocusScale(.57)
		li.btnHidden:SetImageNormalColour(.9,.9,.9,1)
		li.btnHidden:SetImageFocusColour(1,1,1,1)

		li.btnEdit = li:AddChild(ImageButton("images/nuiwp.xml","edit.tex","edit.tex","edit.tex"))
		li.btnEdit:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.EDIT)
		li.btnEdit:SetPosition(liBox:GridX(10,maxCols),liBox:GridY(1,1))
		li.btnEdit:SetNormalScale(.5)
		li.btnEdit:SetFocusScale(.57)
		li.btnEdit:SetImageNormalColour(.9,.9,.9,1)
		li.btnEdit:SetImageFocusColour(1,1,1,1)

		li.btnUp:Hide()
		li.btnDown:Hide()
		li.btnHidden:Hide()
		li.btnEdit:Hide()
	end

	-- Page Navigation

	self.btnPrev = self:AddChild(ImageButton("images/nuiwp.xml","left.tex","left.tex","left.tex"))
	self.btnPrev:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.PREV)
	self.btnPrev:SetPosition(box:GridX(2,5),box:GridY(maxRows,maxRows))
	self.btnPrev:SetNormalScale(.5)
	self.btnPrev:SetFocusScale(.57)
	self.btnPrev:SetImageNormalColour(.9,.9,.9,1)
	self.btnPrev:SetImageFocusColour(1,1,1,1)
	self.btnPrev:SetOnClick(function() self:PrevPage() end)

	self.lblPageIndex = self:AddChild(Text(NUMBERFONT, 32))
	self.lblPageIndex:SetPosition(box:GridX(3,5),box:GridY(maxRows,maxRows))

	self.btnNext = self:AddChild(ImageButton("images/nuiwp.xml","right.tex","right.tex","right.tex"))
	self.btnNext:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.NEXT)
	self.btnNext:SetPosition(box:GridX(4,5),box:GridY(maxRows,maxRows))
	self.btnNext:SetNormalScale(.5)
	self.btnNext:SetFocusScale(.57)
	self.btnNext:SetImageNormalColour(.9,.9,.9,1)
	self.btnNext:SetImageFocusColour(1,1,1,1)
	self.btnNext:SetOnClick(function() self:NextPage() end)

	self.lblXZ = self:AddChild(Text(NUMBERFONT,24))
	self.lblXZ:SetPosition(box:GridX(5,5),box:GridY(maxRows,maxRows))

	-- Close

	self.btnClose = self:AddChild(ImageButton())
	self.btnClose:SetPosition(0,-box:H()/2-20/2)
	self.btnClose:SetScale(.7,.7,.7)
	self.btnClose:SetText(STRINGS.WAYPOINT.UI.BUTTON.CLOSE)
	self.btnClose:SetOnClick(function() self:Hide(true) end)

	-- EXTRA

	-- Movement Prediction toggle button!
	self.btnMpToggle = self:AddChild(ImageButton("images/nuiwp.xml","mpoff.tex","mpoff.tex","mpoff.tex"))
	self.btnMpToggle:SetTooltip(STRINGS.WAYPOINT.UI.BUTTON.TOGGLE_MOVEMENT_PREDICTION)
	self.btnMpToggle:SetPosition(box:GridX(1,10),box:GridY(maxRows,maxRows),0)
	self.btnMpToggle:SetNormalScale(.5)
	self.btnMpToggle:SetFocusScale(.57)
	self.btnMpToggle:SetImageNormalColour(.9,.9,.9,1)
	self.btnMpToggle:SetImageFocusColour(1,1,1,1)
	self.btnMpToggle:SetOnClick(function() self:ToggleMovementPrediction() end)
	if Compatibility:ThePlayer().components.locomotor ~= nil then
		self.btnMpToggle:Hide()
	else
		self:UpdateMovementPredictionButton()
	end
end

function MainWp:SetConfiguration(alwaysShowMp) 
	if alwaysShowMp then
		self.btnMpToggle:Show()
		self:ToggleMovementPrediction()
	end
end

function MainWp:Hide(quiet)
	MainWp._base.Hide(self)
	if quiet == nil or quiet == false then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	end
end

function MainWp:Show(quiet)
	MainWp._base.Show(self)
	if quiet == nil or quiet == false then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	end
	if self.btnMpToggle:IsVisible() then
		self:UpdateMovementPredictionButton()
	end
end

function MainWp:GetAngleToPoint(x,z)
	local p = Compatibility:ThePlayer()
	
	local angleToTarget = p:GetAngleToPoint(x, 0, z)
	local downVector = TheCamera:GetDownVec()
	local downAngle = -math.atan2(downVector.z, downVector.x) / DEGREES
	local angle = (angleToTarget - downAngle) + 90
	while angle > 180 do angle = angle - 360 end
	while angle < -180 do angle = angle + 360 end

	return angle
end

function MainWp:OnUpdate_PlayerPosition(point)
	if self.showCoordinates then
		self.lblXZ:SetString(math.floor(point.x) .. " " .. math.floor(point.z))
	end
	local pageSize = #self.listWaypoint
	for i=1,pageSize,1 do
		local li = self.listWaypoint[i]
		if li:IsVisible() and li.currentWaypoint ~= nil and self.editMode == false then
			local xd = point.x - li.currentWaypoint.coord.x
			local yd = point.y - li.currentWaypoint.coord.y
			local zd = point.z - li.currentWaypoint.coord.z
			local dist = math.sqrt(xd*xd+yd*yd+zd*zd) / TILE_SCALE
			li.lblDistance:SetString(math.floor(dist) .. "m")

			li.lblArrow:SetRotation(self:GetAngleToPoint(
				li.currentWaypoint.coord.x,li.currentWaypoint.coord.z
			))
			if dist < DIRECTION_LINE_MAX_RANGE then
				li.lblArrow:SetScale(.6*dist/DIRECTION_LINE_MAX_RANGE)
			elseif li.lblArrow:GetScale() ~= .6 then
				li.lblArrow:SetScale(.6)
			end
		end
	end
end

function MainWp:LoadData()
	self.waypoints = self.dataContainer:GetValue(self.uwid) or {}
	
	-- migrate old waypoints
	if self.uwid ~= self.uwidOld then
		local oldWaypoints = self.dataContainer:GetValue(self.uwidOld) or {}
		if #oldWaypoints > 0 then
			print("[waypoint] migrating waypoints from " .. self.uwidOld)
			for i,w in pairs(oldWaypoints) do
				self.waypoints[#self.waypoints + i] = w
			end
			self.dataContainer:SetValue(self.uwidOld, {})
		end
	end

	-- load waypoints

	for i,w in pairs(self.waypoints) do
		self:AddMapIcon(w)
	end

	self:UpdateList()
end

function MainWp:SaveData()
	self.dataContainer:SetValue(self.uwid, self.waypoints)
	self.dataContainer:Save()
end

function MainWp:Add()
	local x,y,z = Compatibility:ThePlayer().Transform:GetWorldPosition()
	local gid = Compatibility:TheWorld().Map:GetTileAtPoint(x,y,z)

	-- GROUND from constants which is accessible
	local iground={}
	for k,v in pairs(GROUND) do
		iground[v]=string.gsub(k, "(%a)([%w']*)", function(a,b)
			return a:upper()..b:lower()
		end)
	end

	-- Get unique name depending on area
	local uniqueName = AdjectivesUtility:GetRandomWord()

	local waypoint = Waypoint(
		uniqueName .. ' ' .. iground[gid],
		{["x"]=x,["y"]=y,["z"]=z},
		{
			r=math.random()*.7+.3,
			g=math.random()*.7+.3,
			b=math.random()*.7+.3
		}
	)
	table.insert(self.waypoints, waypoint)
	self:AddMapIcon(waypoint)
	if self.markerMode then
		self:AddMarker(waypoint)
	end
	
	self:LastPage()
end

function MainWp:ClosestWaypointAt(point, maxDist)
	local num = #self.waypoints
	local wid = nil
	local currentDist = 9999
	for i=1,num,1 do
		local li = self.waypoints[i]

		local xd = point.x - li.coord.x
		local yd = point.y - li.coord.y
		local zd = point.z - li.coord.z
		local dist = math.sqrt(xd*xd+yd*yd+zd*zd) / TILE_SCALE
		
		if dist <= currentDist then
			currentDist = dist
			wid = i
		end
	end
	if currentDist < maxDist then
		return wid
	end
	return nil
end

function MainWp:ToggleHidden(wid)
	local waypoint = self.waypoints[wid]
	waypoint.hidden = not waypoint.hidden
	self:SaveData()
	-- print("[waypoint] waypoint hidden toggled!")
	self:UpdateMarker(waypoint)
	self:UpdateList()
	if self.markerMode then
		if waypoint.hidden then
			self:RemoveMarker(waypoint)
		else
			self:AddMarker(waypoint)
		end
	end
end

function MainWp:MoveUp(wid)
	if wid-1 > 0 then
		local temp = self.waypoints[wid-1]
		self.waypoints[wid-1] = self.waypoints[wid]
		self.waypoints[wid] = temp
		self:SaveData()
		-- print("[waypoint] waypoint moved up saved!")
		self:UpdateList()
	end
end

function MainWp:MoveDown(wid)
	if wid < #self.waypoints then
		local temp = self.waypoints[wid+1]
		self.waypoints[wid+1] = self.waypoints[wid]
		self.waypoints[wid] = temp
		self:SaveData()
		-- print("[waypoint] waypoint moved down saved!")
		self:UpdateList()
	end
end

function MainWp:Edit(wid)
	if self.dialogEdit == nil then
		local waypoint = self.waypoints[wid]
		self.dialogEdit = self:AddChild(DialogEdit(nil,nil,self.skin,self.colourVariety)) 
		self.dialogEdit:SetWaypoint(waypoint)
		self.dialogEdit:SetSuccessCallback(function()
			waypoint.name = self.dialogEdit.inputName.input:GetText()
			local x = tonumber(self.dialogEdit.inputX.input:GetText())
			local z = tonumber(self.dialogEdit.inputZ.input:GetText())
			if x ~= nil then
				waypoint.coord.x = x
			end
			if z ~= nil then
				waypoint.coord.z = z
			end
			local r,g,b = self.dialogEdit.palette:GetRGB()
			waypoint.colour.r = r
			waypoint.colour.g = g
			waypoint.colour.b = b
			self:SaveData()
			print("[waypoint] edit saved!")
			self:UpdateList()
			self:UpdateMarker(waypoint)
			self:KillEditDialog()
		end)
		self.dialogEdit:SetCancelCallback(function()
			self:KillEditDialog()
		end)
		self.dialogEdit:SetDeleteCallback(function()
			self:Remove(wid)
			self:KillEditDialog()
		end)
	else
		print("[waypoint] already editing!")
	end
end

function MainWp:KillEditDialog()
	self.dialogEdit:Kill()
	self.dialogEdit = nil
end

function MainWp:KillMpDialog()
	self.dialogMp:Kill()
	self.dialogMp = nil
end

function MainWp:Remove(wid)
	-- Remove indicator
	local waypoint = self.waypoints[wid]

	if waypoint ~= nil then
		if self.markerMode then
			self:RemoveMarker(waypoint)
		end
		self:RemoveMapIcon(waypoint)
	end

	table.remove(self.waypoints,wid)
	self:UpdateList()
	self:SaveData()
end

function MainWp:AddMarker(waypoint)
	if not waypoint.hidden then
		local marker = SpawnPrefab("flagplacer")
		if marker ~= nil then
			if self.markers == nil then
				self.markers = {}
			end
			marker.Transform:SetPosition(waypoint.coord.x, waypoint.coord.y, waypoint.coord.z)
			self.markers[waypoint] = marker

			-- Add indicator
			local indicator = self.im:AddIndicator(marker)
			indicator:SetName(waypoint.name)
			indicator:SetColour({waypoint.colour.r,waypoint.colour.g,waypoint.colour.b})

			if self.disableAutoTravel then
				indicator:SetTooltip(
					waypoint.name
				)
			else
				indicator:SetTooltip(
					STRINGS.LMB .. " " ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.PREFIX_TRAVELTO ..
					waypoint.name ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.SUFFIX_TRAVELTO
				)
				indicator:SetCallback(function()
					self:MovePlayerTo(waypoint)
				end)
			end
			-- Compatibility:ThePlayer().HUD:AddTargetIndicator(marker)
		else
			print("[waypoint] failed to spawn flagplacer!")
		end
		-- self:AddMapIcon(waypoint)
	end
end
function MainWp:RemoveMarker(waypoint)
	local marker = self.markers[waypoint]
	self.markers[waypoint] = nil
	if marker ~= nil then
		self.im:RemoveIndicator(marker)
		marker:Remove()
	end
	-- Compatibility:ThePlayer().HUD:RemoveTargetIndicator(marker)
	-- self:RemoveMapIcon(waypoint)
end

function MainWp:AddMapIcon(waypoint)
	if TheFrontEnd.NMapIconTemplateManager then
		if self.mapIcons == nil then
			self.mapIcons = {}
		end
		local template = NMapIconTemplate()
		template:SetWorldPosition(waypoint.coord.x, waypoint.coord.y, waypoint.coord.z)
		template:SetWidget(function(inst)
			local root = inst:AddChild(NPanel("MapIconRoot"))
			
			local icon = root:AddChild(ImageButton("images/flag.xml","flag.tex","flag.tex","flag.tex"))
			icon:SetScale(.2)
			icon:SetNormalScale(.9)
			icon:SetFocusScale(1)
			icon:SetImageNormalColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
			icon:SetImageFocusColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)

			if self.disableAutoTravel then
				icon:SetTooltip(
					waypoint.name
				)
			else
				icon:SetTooltip(
					STRINGS.LMB .. " " ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.PREFIX_TRAVELTO ..
					waypoint.name ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.SUFFIX_TRAVELTO
				)
				icon:SetOnClick(function()
					self:MovePlayerTo(waypoint)
				end)
			end

			local label = root:AddChild(Text(TALKINGFONT, 25, waypoint.name))
			label:SetColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
			label:SetPosition(0, 45, 0)

			-- local OldSetScale = root.SetScale
			-- function root:SetScale(pos, y, z)

			-- end

			return root
		end)
		self.mapIcons[waypoint] = TheFrontEnd.NMapIconTemplateManager:AddTemplate(template)
	end
end
function MainWp:UpdateMapIcon(waypoint)
	if TheFrontEnd.NMapIconTemplateManager then
		local icon = self.mapIcons[waypoint]
		if TheFrontEnd.NMapIconTemplateManager:HasTemplate(icon) then
			icon:SetWorldPosition(waypoint.coord.x, waypoint.coord.y, waypoint.coord.z)
		end
	end
end
function MainWp:RemoveMapIcon(waypoint)
	if TheFrontEnd.NMapIconTemplateManager then
		TheFrontEnd.NMapIconTemplateManager:RemoveTemplate(self.mapIcons[waypoint])
		self.mapIcons[waypoint] = nil
	end
end

function MainWp:ContainsMarker(waypoint)
	if not self.markers then return end
	for i,v in pairs(self.markers) do
		if i == waypoint then
			return true
		end
	end
	return false
end

function MainWp:UpdateMarker(waypoint)
	self:UpdateMapIcon(waypoint)
	if self:ContainsMarker(waypoint) then
		local marker = self.markers[waypoint]
		if marker ~= nil and self.im:HasIndicator(marker) then
			marker.Transform:SetPosition(
				waypoint.coord.x,
				waypoint.coord.y,
				waypoint.coord.z)
			local indicator = self.im:GetIndicator(marker)
			indicator:SetName(waypoint.name)
			indicator:SetColour({waypoint.colour.r,waypoint.colour.g,waypoint.colour.b})
			
			if self.disableAutoTravel then
				indicator:SetTooltip(
					waypoint.name
				)
			else
				indicator:SetTooltip(
					STRINGS.LMB .. " " ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.PREFIX_TRAVELTO ..
					waypoint.name ..
					STRINGS.WAYPOINT.UI.INDICATOR.BUTTON.SUFFIX_TRAVELTO
				)
				indicator:SetCallback(function()
					self:MovePlayerTo(waypoint)
				end)
			end
		end
	end
end

function MainWp:ToggleEditMode()
	if self.editMode then
		self.editMode = false
		self.btnEdit:SetImageNormalColour(.9,.9,.9,TOGGLE_ALPHA_DISABLED)
		self.btnEdit:SetImageFocusColour(1,1,1,TOGGLE_ALPHA_HOVER)
	else
		self.editMode = true
		self.btnEdit:SetImageNormalColour(.9,.9,.9,1)
		self.btnEdit:SetImageFocusColour(1,1,1,1)
	end
	for i,li in pairs(self.listWaypoint) do
		if self.editMode then
			li.btnHidden:Show()
			li.btnUp:Show()
			li.btnDown:Show()
			li.btnEdit:Show()
			li.lblX:Hide()
			li.lblZ:Hide()
			li.lblDistance:Hide()
			li.lblArrow:Hide()
			li.btnNavigate:Hide()
		else
			li.btnHidden:Hide()
			li.btnUp:Hide()
			li.btnDown:Hide()
			li.btnEdit:Hide()
			li.lblX:Show()
			li.lblZ:Show()
			li.lblDistance:Show()
			li.lblArrow:Show()
			li.btnNavigate:Show()
		end
	end
end

function MainWp:ToggleMarkerMode()
	if self.markerMode then
		self.markerMode = false
		self.btnIndicators:SetImageNormalColour(.9,.9,.9,TOGGLE_ALPHA_DISABLED)
		self.btnIndicators:SetImageFocusColour(1,1,1,TOGGLE_ALPHA_HOVER)
		if self.markers ~= nil then
			for i,marker in pairs(self.markers) do
				self:RemoveMarker(i)
			end
			self.markers = {}
			print("[waypoint] markers removed.")
		end
	else
		self.markerMode = true
		self.btnIndicators:SetImageNormalColour(.9,.9,.9,1)
		self.btnIndicators:SetImageFocusColour(1,1,1,1)
		for i,w in pairs(self.waypoints) do
			self:AddMarker(w)
		end
		print("[waypoint] markers added.")
	end
end

function MainWp:ToggleMovementPrediction()
	if Compatibility:ThePlayer().components.locomotor == nil then
		Compatibility:ThePlayer():EnableMovementPrediction(true)
	else
		Compatibility:ThePlayer():EnableMovementPrediction(false)
	end
	-- Check again to correct image
	self:UpdateMovementPredictionButton()
end

function MainWp:UpdateMovementPredictionButton()
	if Compatibility:ThePlayer().components.locomotor == nil then
		self.btnMpToggle:SetTextures("images/nuiwp.xml","mpoff.tex","mpoff.tex","mpoff.tex")
		self.btnMpToggle:SetImageNormalColour(.9,.9,.9,1)
		self.btnMpToggle:SetImageFocusColour(1,1,1,1)

	else
		self.btnMpToggle:SetTextures("images/nuiwp.xml","mpon.tex","mpon.tex","mpon.tex")
		self.btnMpToggle:SetImageNormalColour(.9,.9,.9,1)
		self.btnMpToggle:SetImageFocusColour(1,1,1,1)
	end
end

function MainWp:NextPage()
	local pageSize = #self.listWaypoint
	if self.pageIndex < math.ceil(#self.waypoints / pageSize) then
		self.pageIndex = self.pageIndex + 1
		self:UpdateList()
	end
end

function MainWp:PrevPage()
	if self.pageIndex > 1 then
		self.pageIndex = self.pageIndex - 1
		self:UpdateList()
	end
end

function MainWp:LastPage()
	local pageSize = #self.listWaypoint
	local pageCap = math.ceil(#self.waypoints / pageSize)
	self.pageIndex = pageCap
	self:UpdateList()
end

function MainWp:UpdateList()
	local pageSize = #self.listWaypoint
	local pageCap = math.ceil(#self.waypoints / pageSize)
	for i=1,pageSize,1 do
		local wid = (self.pageIndex-1)*pageSize+i
		local waypoint = self.waypoints[wid];
		local li = self.listWaypoint[i]
		li.currentWaypoint = waypoint
		self:DisplayWaypoint(li, waypoint)
		li.lblName:SetCallback(function()
			waypoint.name = li.lblName.input:GetText()
			self:UpdateMarker(waypoint)
			self:SaveData()
		end)
		li.btnNavigate:SetOnClick(function()
			if not self.disableAutoTravel then
				self:MovePlayerTo(waypoint)
			end
		end)
		li.btnHidden:SetOnClick(function()
			self:ToggleHidden(wid)
		end)
		li.btnUp:SetOnClick(function()
			self:MoveUp(wid)
		end)
		li.btnDown:SetOnClick(function()
			self:MoveDown(wid)
		end)
		li.btnEdit:SetOnClick(function()
			self:Edit(wid)
		end)
	end
	if self.pageIndex > pageCap then
		self:LastPage()
	else
		self.lblPageIndex:SetString(self.pageIndex .. "/" .. pageCap)
	end

	self:SaveData()
end

function MainWp:DisplayWaypoint(li, waypoint)
	if type(waypoint)=="table" then
		li.lblName.input:SetText(waypoint.name)
		li.lblName.input:SetColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		if self.showCoordinates then
			li.lblX:SetString(math.floor(waypoint.coord.x))
			li.lblZ:SetString(math.floor(waypoint.coord.z))
		end
		li.btnNavigate:SetImageNormalColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		li.btnNavigate:SetImageFocusColour(waypoint.colour.r,waypoint.colour.g,waypoint.colour.b,1)
		if waypoint.hidden then
			li.btnHidden:SetTextures("images/nuiwp.xml","markeroff.tex","markeroff.tex","markeroff.tex")
		else
			li.btnHidden:SetTextures("images/nuiwp.xml","markeron.tex","markeron.tex","markeron.tex")
		end
		li:Show()
	else
		li:Hide()
	end
end

function MainWp:MovePlayerTo(waypoint)
	-- Compatibility:ThePlayer():EnableMovementPrediction(false)
	if Compatibility:ThePlayer().components.locomotor ~= nil and waypoint then
		local locomotor = Compatibility:ThePlayer().components.locomotor
		local point = Point(waypoint.coord.x,waypoint.coord.y,waypoint.coord.z)
		print("[waypoint] moving to " .. point.x .. ", " .. point.y .. ", " .. point.z)	
		locomotor:GoToPoint(point, nil, true)
	elseif not self.btnMpToggle:IsVisible() then
		print("[waypoint] Movement Prediction is disabled!")
		self.btnMpToggle:Show()
		self:ShowMpWarning()
	end
end

function MainWp:ShowMpWarning()
	if self.dialogMp == nil then
		self.dialogMp = self:AddChild(DialogMp(nil,nil,self.skin))
		self.dialogMp:SetOkayCallback(function()
			self:KillMpDialog()
		end)
	else
		print("[waypoint] already editing!")
	end
end

return MainWp