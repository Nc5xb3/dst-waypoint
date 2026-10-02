WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "Toggle Waypoint"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "Waypoint indicators",
			ADD_REMOVE = "Add/remove waypoint",
		},
		MENU = {
			TITLE = "- Waypoint -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "Toggle Edit Mode",
			CONFIGURATIONS = "Configurations",
			TOGGLE_INDICATORS = "Toggle Indicators",
			TOGGLE_MOVEMENT_PREDICTION = "Toggle Movement Prediction",

			ADD = "Add Waypoint",

			PREV = "Previous Page",
			NEXT = "Next Page",

			TRAVEL = "Travel",

			MOVE_UP = "Up",
			MOVE_DOWN = "Down",
			TOGGLE_VISIBILITY = "Toggle Visiblity",
			EDIT = "Edit",

			CLOSE = "Close",
			EDIT_KEYBINDS = "Keybinds",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "Travel to ",
				SUFFIX_TRAVELTO = ""
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "Save",
				CANCEL = "Cancel",
				OKAY = "Okay",
				DELETE = "Delete",
				CLOSE = "Close",
			},
			EDIT = {
				TITLE = "Modify Waypoint",
				NAME = "Name",
				COORDINATES = "Coordinates",
				COLOUR = "Colour",
				RANDOMIZE = "Randomize",
			},
			DELETE_CONFIRM = {
				TITLE = "Delete waypoint?",
				MESSAGE = "\"%s\" will be deleted. This can't be undone.",
			},
			MP = {
				TITLE = "Information",
				MESSAGE1 = "Lag Compensation is NOT predictive, meaning",
				MESSAGE2 = "'movement prediction' is currently disabled!",
				MESSAGE3 = "Due to this, traveling to a waypoint is not possible.",
				MESSAGE4 = "A toggle button is now visible allowing you to toggle",
				MESSAGE5 = "movement prediction in order to use travel.",
			},
			KEYBINDS = {
				TITLE = "Keybinds",
				CAPTURE_TITLE = "Press a Key",
				INSTRUCTIONS = "Click a button to change a key (A-Z only).",
				INSTRUCTIONS_LINE1 = "Press a key to bind,",
				INSTRUCTIONS_LINE2 = "or Backspace to remove the bind.",
				ACTION_TOGGLE_UI = "Toggle UI visibility",
				ACTION_TOGGLE_INDICATORS = "Toggle indicators",
				NONE = "None",
			},
			CONFIG = {
				TITLE = "Configurations",
				HUD_BUTTON = "HUD button",
				MAP_ICONS = "Map icons",
				MAP_ICONS_ALL = "All",
				MAP_ICONS_VISIBLE = "Visible only",
				MAP_ICONS_OFF = "Off",
				COORDINATES = "Coordinates",
				CLICK_TO_TRAVEL = "Click flag to travel",
				ON = "On",
				OFF = "Off",
				DEBUG_BUTTON = "Debug info",
				KEYBINDS_DESC = "Window: %s   Indicators: %s",
				HUD_BUTTON_DESC_ON = "A button on screen opens the waypoint list",
				HUD_BUTTON_DESC_OFF = "No on-screen button; use your keybind",
				MAP_ICONS_DESC_ALL = "Every waypoint has a flag on the map",
				MAP_ICONS_DESC_VISIBLE = "Hidden waypoints are left off the map",
				MAP_ICONS_DESC_OFF = "No waypoint flags on the map",
				COORDINATES_DESC_ON = "X/Z shown in the waypoint list",
				COORDINATES_DESC_OFF = "Coordinates are not shown",
				CLICK_TO_TRAVEL_DESC_ON = "Click a waypoint flag to walk there",
				CLICK_TO_TRAVEL_DESC_OFF = "Clicking a flag does nothing",
				DEBUG_TITLE = "Debug Information",
				UWID_LABEL = "UWID:",
				WAYPOINT_COUNT_LABEL = "Waypoints:",
			},
		},
	},
}