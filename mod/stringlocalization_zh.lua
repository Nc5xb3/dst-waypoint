WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "切换路标"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "路标指示器",
			ADD_REMOVE = "添加/删除路标",
		},
		MENU = {
			TITLE = "- 路标 -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "切换编辑模式",
			CONFIGURATIONS = "设置",
			TOGGLE_INDICATORS = "切换指示器",
			TOGGLE_MOVEMENT_PREDICTION = "切换移动预测",

			ADD = "添加路标",

			PREV = "上一页",
			NEXT = "下一页",

			TRAVEL = "前往",

			MOVE_UP = "上移",
			MOVE_DOWN = "下移",
			TOGGLE_VISIBILITY = "切换显示",
			EDIT = "编辑",

			CLOSE = "关闭",
			EDIT_KEYBINDS = "按键设置",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "前往 ",
				SUFFIX_TRAVELTO = ""
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "保存",
				CANCEL = "取消",
				OKAY = "确定",
				DELETE = "删除",
				CLOSE = "关闭",
			},
			EDIT = {
				TITLE = "修改路标",
				NAME = "Name",
				COORDINATES = "坐标",
				COLOUR = "颜色",
				RANDOMIZE = "随机",
			},
			DELETE_CONFIRM = {
				TITLE = "删除路标？",
				MESSAGE = "将删除“%s”，此操作无法撤销。",
			},
			MP = {
				TITLE = "提示",
				MESSAGE1 = "延迟补偿不是“预测”模式，",
				MESSAGE2 = "也就是说“移动预测”当前已关闭！",
				MESSAGE3 = "因此无法自动前往路标。",
				MESSAGE4 = "现在会显示一个切换按钮，",
				MESSAGE5 = "开启移动预测后即可使用前往功能。",
			},
			KEYBINDS = {
				TITLE = "按键设置",
				CAPTURE_TITLE = "请按下按键",
				INSTRUCTIONS = "点击按钮更改按键（仅限 A-Z）。",
				INSTRUCTIONS_LINE1 = "按下要绑定的按键，",
				INSTRUCTIONS_LINE2 = "或按 Backspace 清除绑定。",
				ACTION_TOGGLE_UI = "显示/隐藏界面",
				ACTION_TOGGLE_INDICATORS = "显示/隐藏指示器",
				NONE = "无",
			},
			CONFIG = {
				TITLE = "设置",
				HUD_BUTTON = "HUD 按钮",
				MAP_ICONS = "地图图标",
				MAP_ICONS_ALL = "全部",
				MAP_ICONS_VISIBLE = "仅可见",
				MAP_ICONS_OFF = "关闭",
				COORDINATES = "坐标",
				CLICK_TO_TRAVEL = "点击旗帜前往",
				ON = "开",
				OFF = "关",
				DEBUG_BUTTON = "调试信息",
				KEYBINDS_DESC = "窗口：%s   指示器：%s",
				HUD_BUTTON_DESC_ON = "屏幕上的按钮可打开路标列表",
				HUD_BUTTON_DESC_OFF = "不显示按钮，请使用快捷键",
				MAP_ICONS_DESC_ALL = "所有路标都在地图上显示旗帜",
				MAP_ICONS_DESC_VISIBLE = "已隐藏的路标不在地图上显示",
				MAP_ICONS_DESC_OFF = "地图上不显示路标旗帜",
				COORDINATES_DESC_ON = "在路标列表中显示 X/Z",
				COORDINATES_DESC_OFF = "不显示坐标",
				CLICK_TO_TRAVEL_DESC_ON = "点击路标旗帜即可走过去",
				CLICK_TO_TRAVEL_DESC_OFF = "点击旗帜不会移动",
				DEBUG_TITLE = "调试信息",
				UWID_LABEL = "UWID：",
				WAYPOINT_COUNT_LABEL = "路标数：",
			},
		},
	},
}