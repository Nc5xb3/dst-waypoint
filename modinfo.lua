name = "Waypoint" 
description = "The ability to add a waypoint at your position and bring up a list of waypoints to travel towards."
author = "Nc5xb3"
version = "1.0.7d"

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

local sizeList = {}
for i=1,6 do
	local size = 240 + 60 * i
	sizeList[i] = {description = size, data = size}
end

configuration_options =
{
    {
        name = "LOCALIZATION_MOD_WAYPOINT",
        label = "Localization",
        hover = "Sets the localization",
        options = {
        	{description = "English", data = "en"},
        	{description = "Pусский", data = "ru"}, -- Translation by Чapли (http://steamcommunity.com/profiles/76561198019876843)
        	{description = "日本語", data = "jp"},
        },
        default = "en",
    },
    {
        name = "SKIN_MOD_WAYPOINT",
        label = "Skin",
        hover = "Sets the skin",
        options = {
        	{description = "Plain", data = 0},
        	{description = "DST-like", data = 1}
        },
        default = 1,
    },
    {
        name = "SHOW_WAYPOINT_INDICATORS",
        label = "Show waypoint indicators",
        hover = "Waypoint indicators visibility on startup, can be toggled in-game",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = true,
    },
    {
        name = "ENABLE_CONTROLLER_SUPPORT",
        label = "Enable controller support",
        hover = "Controller support; if conflicts arise disable",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = true,
    },
    {
        name = "KEY_TOGGLE_MOD_WAYPOINT",
        label = "Toggle visibility",
        hover = "Toggles the visibility of the user interface",
        options = keysList,
        default = 120,
    },
    {
        name = "KEY_TOGGLE_MOD_WAYPOINT_INDICATORS",
        label = "Toggle indicators",
        hover = "Toggles the visibility of the indicators",
        options = keysList,
        default = 0,
    },
    {
        name = "WIDTH_MOD_WAYPOINT",
        label = "Width",
        hover = "Sets the width size of the window",
        options = sizeList,
        default = 360,
    },
    {
        name = "HEIGHT_MOD_WAYPOINT",
        label = "Height",
        hover = "Sets the height size of the window",
        options = sizeList,
        default = 480,
    },
    {
        name = "COLOUR_PALETTE_VARIETY",
        label = "Colour variety",
        hover = "Sets how much variety of colours are available when editing waypoint flags",
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
        name = "HIDE_HUD_ICON_WAYPOINT",
        label = "Hide the hud icon",
        hover = "Sets the option to hide the waypoint hud icon",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = false,
    },
    {
        name = "DISABLE_CUSTOM_MAP_ICONS_WAYPOINT",
        label = "Disable custom map icons",
        hover = "Sets the option to disable waypoint map icons",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = false,
    },
    {
        name = "ALWAYS_SHOW_MP_WAYPOINT",
        label = "DST - Show MP Toggle",
        hover = "Sets the option to always show the movement prediction toggle button",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = false,
    },
    {
        name = "SHOW_COORDINATES",
        label = "Show map coordinates",
        hover = "Show current play and all waypoints coordinates",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = false,
    },
    {
        name = "DISABLE_AUTO_TRAVEL",
        label = "Disable auto travel",
        hover = "Disable the ability to click on a waypoint flag for auto travel",
        options = {
            {description = "False", data = false},
            {description = "True", data = true}
        },
        default = false,
    },
}
