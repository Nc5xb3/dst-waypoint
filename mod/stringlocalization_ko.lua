WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "웨이포인트 열기/닫기"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "웨이포인트 표시기",
			ADD_REMOVE = "웨이포인트 추가/삭제",
		},
		MENU = {
			TITLE = "- 웨이포인트 -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "편집 모드 전환",
			CONFIGURATIONS = "설정",
			TOGGLE_INDICATORS = "표시기 켜기/끄기",
			TOGGLE_MOVEMENT_PREDICTION = "이동 예측 켜기/끄기",

			ADD = "웨이포인트 추가",

			PREV = "이전 페이지",
			NEXT = "다음 페이지",

			TRAVEL = "이동",

			MOVE_UP = "위로",
			MOVE_DOWN = "아래로",
			TOGGLE_VISIBILITY = "표시 전환",
			EDIT = "편집",

			CLOSE = "닫기",
			EDIT_KEYBINDS = "키 설정",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "",
				SUFFIX_TRAVELTO = "(으)로 이동"
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "저장",
				CANCEL = "취소",
				OKAY = "확인",
				DELETE = "삭제",
				CLOSE = "닫기",
			},
			EDIT = {
				TITLE = "웨이포인트 수정",
				NAME = "Name",
				COORDINATES = "좌표",
				COLOUR = "색상",
				RANDOMIZE = "무작위",
			},
			DELETE_CONFIRM = {
				TITLE = "웨이포인트를 삭제할까요?",
				MESSAGE = "'%s'이(가) 삭제됩니다. 되돌릴 수 없습니다.",
			},
			MP = {
				TITLE = "안내",
				MESSAGE1 = "지연 보상이 '예측' 모드가 아니므로",
				MESSAGE2 = "'이동 예측'이 현재 꺼져 있습니다!",
				MESSAGE3 = "이 때문에 웨이포인트로 이동할 수 없습니다.",
				MESSAGE4 = "이제 전환 버튼이 표시되며,",
				MESSAGE5 = "이동 예측을 켜면 이동 기능을 사용할 수 있습니다.",
			},
			KEYBINDS = {
				TITLE = "키 설정",
				CAPTURE_TITLE = "키를 누르세요",
				INSTRUCTIONS = "버튼을 눌러 키를 변경하세요 (A-Z만 가능).",
				INSTRUCTIONS_LINE1 = "지정할 키를 누르거나,",
				INSTRUCTIONS_LINE2 = "Backspace로 지정을 해제하세요.",
				ACTION_TOGGLE_UI = "UI 표시 전환",
				ACTION_TOGGLE_INDICATORS = "표시기 전환",
				NONE = "없음",
			},
			CONFIG = {
				TITLE = "설정",
				HUD_BUTTON = "HUD 버튼",
				MAP_ICONS = "지도 아이콘",
				MAP_ICONS_ALL = "전체",
				MAP_ICONS_VISIBLE = "보이는 것만",
				MAP_ICONS_OFF = "끔",
				COORDINATES = "좌표",
				CLICK_TO_TRAVEL = "깃발 클릭으로 이동",
				ON = "켬",
				OFF = "끔",
				DEBUG_BUTTON = "디버그 정보",
				KEYBINDS_DESC = "창: %s   표시기: %s",
				HUD_BUTTON_DESC_ON = "화면 버튼으로 웨이포인트 목록을 엽니다",
				HUD_BUTTON_DESC_OFF = "화면 버튼 없음, 단축키를 사용하세요",
				MAP_ICONS_DESC_ALL = "모든 웨이포인트를 지도에 깃발로 표시",
				MAP_ICONS_DESC_VISIBLE = "숨긴 웨이포인트는 지도에 표시하지 않음",
				MAP_ICONS_DESC_OFF = "지도에 깃발을 표시하지 않음",
				COORDINATES_DESC_ON = "목록에 X/Z 좌표 표시",
				COORDINATES_DESC_OFF = "좌표를 표시하지 않음",
				CLICK_TO_TRAVEL_DESC_ON = "깃발을 클릭하면 그곳으로 걸어갑니다",
				CLICK_TO_TRAVEL_DESC_OFF = "깃발을 클릭해도 이동하지 않음",
				DEBUG_TITLE = "디버그 정보",
				UWID_LABEL = "UWID:",
				WAYPOINT_COUNT_LABEL = "웨이포인트 수:",
			},
		},
	},
}