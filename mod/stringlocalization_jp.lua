WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "ウェイポイントをトグル"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "ウェイポイント表示",
			ADD_REMOVE = "ウェイポイント追加/削除",
		},
		MENU = {
			TITLE = "- ウェイポイント -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "トグル編集モード",
			CONFIGURATIONS = "設定",
			TOGGLE_INDICATORS = "場所をトグル",
			TOGGLE_MOVEMENT_PREDICTION = "動きの予測をトグル",

			ADD = "ウェイポイントを追加",

			PREV = "前のページ",
			NEXT = "次のページ",

			TRAVEL = "行く",

			MOVE_UP = "上",
			MOVE_DOWN = "下",
			TOGGLE_VISIBILITY = "視認性をトグル",
			EDIT = "変化する",

			CLOSE = "閉じる",
			EDIT_KEYBINDS = "キー設定",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "",
				SUFFIX_TRAVELTO = "に行く"
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "セーブ",
				CANCEL = "キャンセル",
				OKAY = "はい",
				DELETE = "デリート",
				CLOSE = "閉じる",
			},
			EDIT = {
				TITLE = "変化する",
				NAME = "名称",
				COORDINATES = "座標",
				COLOUR = "色",
				RANDOMIZE = "ランダム",
			},
			DELETE_CONFIRM = {
				TITLE = "ウェイポイントを削除しますか？",
				MESSAGE = "「%s」を削除します。元に戻せません。",
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
				TITLE = "キー設定 (Keybinds)",
				CAPTURE_TITLE = "キーを押す",
				INSTRUCTIONS = "ボタンをクリックしてキーを変更 (A-Z のみ)。",
				INSTRUCTIONS_LINE1 = "キーを押して設定、",
				INSTRUCTIONS_LINE2 = "Backspace で解除します。",
				ACTION_TOGGLE_UI = "UI の表示切替",
				ACTION_TOGGLE_INDICATORS = "インジケータの切替",
				NONE = "なし",
			},
			INDICATOR_AREA = {
				TITLE = "インジケーター範囲",
				SHAPE = "形",
				SIZE = "大きさ",
				SHAPE_RECTANGLE = "四角形",
				SHAPE_ELLIPSE = "楕円",
				SHAPE_CIRCLE = "円",
				NAMES = "名前",
				NAMES_ALWAYS = "常に表示",
				NAMES_HOVER = "ホバー時",
				PREVIEW_NOTE = "点線＝インジケーターの位置",
			},
			CONFIG = {
				TITLE = "設定",
				HUD_BUTTON = "HUDボタン",
				MAP_ICONS = "マップアイコン",
				MAP_ICONS_ALL = "すべて",
				MAP_ICONS_VISIBLE = "表示中のみ",
				MAP_ICONS_OFF = "オフ",
				COORDINATES = "座標",
				CLICK_TO_TRAVEL = "旗クリックで移動",
				ON = "オン",
				OFF = "オフ",
				DEBUG_BUTTON = "デバッグ情報",
				KEYBINDS_DESC = "ウィンドウ: %s   表示: %s",
				HUD_BUTTON_DESC_ON = "画面上のボタンでリストを開きます",
				HUD_BUTTON_DESC_OFF = "画面ボタンなし（キーで開きます）",
				MAP_ICONS_DESC_ALL = "すべての旗をマップに表示",
				MAP_ICONS_DESC_VISIBLE = "非表示のウェイポイントはマップに出ません",
				MAP_ICONS_DESC_OFF = "マップに旗を表示しません",
				COORDINATES_DESC_ON = "リストにX/Z座標を表示",
				COORDINATES_DESC_OFF = "座標を表示しません",
				CLICK_TO_TRAVEL_DESC_ON = "旗をクリックするとそこへ歩きます",
				CLICK_TO_TRAVEL_DESC_OFF = "旗をクリックしても移動しません",
				INDICATOR_AREA = "インジケーター範囲",
				INDICATOR_AREA_DESC = "%s・画面の%s%%",
				DEBUG_TITLE = "デバッグ情報",
				UWID_LABEL = "UWID:",
				WAYPOINT_COUNT_LABEL = "ウェイポイント:",
			},
		},
	},
}