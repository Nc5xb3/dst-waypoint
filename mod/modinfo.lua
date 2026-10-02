name = "Waypoint Mod" 
description = "The ability to add a waypoint at your position and bring up a list of waypoints to travel towards."
author = "Nc5xb3"
version = "1.1.2"

forumthread = "/files/file/1580-waypoint/"

api_version = 6
api_version_dst = 10

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true
dst_compatible = true

all_clients_require_mod = false
client_only_mod = true

standalone = false
restart_require = false

-- load after global position to fix MapWidget overrides
priority = -10000

server_filter_tags = { "waypoint" }

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local keysList = {}
for i=1,#alphabet do
	keysList[i] = {description = alphabet[i], data = 96 + i}
end
keysList[#alphabet + 1] = {description = "None", data = 0}

configuration_options =
{
    {
        name = "LOCALIZATION_MOD_WAYPOINT",
        label = "Language",
        hover = "Auto matches the game's language (English if not supported)",
        options = {
        	{description = "Auto", data = "auto"},
        	{description = "English", data = "en"},
        	{description = "Pусский", data = "ru"}, -- Translation for <v1.0.7 by Чapли (http://steamcommunity.com/profiles/76561198019876843)
        	{description = "日本語", data = "jp"}, -- MTL
        	{description = "简体中文", data = "zh"}, -- MTL
        	{description = "한국어", data = "ko"}, -- MTL
        	{description = "Português (BR)", data = "pt"}, -- MTL
        },
        default = "auto",
    },
    {
        name = "SKIN_MOD_WAYPOINT",
        label = "Window style",
        hover = "Look of the waypoint window",
        options = {
        	{description = "Plain", data = 0},
        	{description = "DST-like", data = 1}
        },
        default = 1,
    },
    {
        name = "COLOUR_PALETTE_VARIETY",
        label = "Colour choices",
        hover = "How many colours the flag colour picker offers",
        options = {
            {description = "Minimal", data = 15},
            {description = "Less", data = 10},
            {description = "Moderate", data = 8},
            {description = "More", data = 6},
            {description = "Maximal", data = 3},
        },
        default = 8,
    },
    {
        name = "ALWAYS_SHOW_MP_WAYPOINT",
        label = "Movement prediction button",
        hover = "Travel needs movement prediction (lag compensation) on. The button to switch it appears automatically when it's off; set Always to keep it visible",
        options = {
            {description = "When needed", data = false},
            {description = "Always", data = true}
        },
        default = false,
    },
    -- Controller support is always on now (ENABLE_CONTROLLER_SUPPORT in modmain.lua).
    -- Kept here commented out in case it needs to come back as an option.
    -- {
    --     name = "ENABLE_CONTROLLER_SUPPORT",
    --     label = "Controller support",
    --     hover = "Social menu (Back/View): Waypoints opens the window (d-pad/stick to move, A select, B back), Waypoint indicators toggles them",
    --     options = {
    --         {description = "Off", data = false},
    --         {description = "On", data = true}
    --     },
    --     default = true,
    -- },
}
