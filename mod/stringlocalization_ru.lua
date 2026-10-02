WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "Координаты на карте"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "Индикаторы",
			ADD_REMOVE = "Добавить/удалить координаты",
		},
		MENU = {
			TITLE = "- Координаты -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "Редактирование (Вкл/Выкл)",
			CONFIGURATIONS = "Настройки",
			TOGGLE_INDICATORS = "Индикаторы (Вкл/Выкл)",
			TOGGLE_MOVEMENT_PREDICTION = "Анализ перемещений (Вкл/Выкл)",

			ADD = "Добавить координаты",

			PREV = "Предыдущая стр",
			NEXT = "Следующая стр",

			TRAVEL = "Путешествие",

			MOVE_UP = "Выше",
			MOVE_DOWN = "Ниже",
			TOGGLE_VISIBILITY = "Видимость на карте (вкл/выкл)",
			EDIT = "Редактировать",

			CLOSE = "Закрыть",
			EDIT_KEYBINDS = "Клавиши",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "Отправиться к ",
				SUFFIX_TRAVELTO = ""
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "Сохранить",
				CANCEL = "Отменить",
				OKAY = "Готово",
				DELETE = "Удалить",
				CLOSE = "Закрыть",
			},
			EDIT = {
				TITLE = "Редактировать координаты",
				NAME = "наименование",
				COORDINATES = "Координаты",
				COLOUR = "Цвет",
				RANDOMIZE = "Случайно",
			},
			DELETE_CONFIRM = {
				TITLE = "Удалить координаты?",
				MESSAGE = "«%s» будет удалено. Это нельзя отменить.",
			},
			MP = {
				TITLE = "Информация",
				MESSAGE1 = "Компенсация лагов не включена, значит анализ",
				MESSAGE2 = "перемещений отключен! В связи с этим,",
				MESSAGE3 = "расчет маршрута невозможен. Вы можете",
				MESSAGE4 = "использовать кнопку для включения анализа",
				MESSAGE5 = "перемещений, чтобы отправиться к координатам.",
			},
			KEYBINDS = {
				TITLE = "Клавиши (Keybinds)",
				CAPTURE_TITLE = "Нажмите клавишу",
				INSTRUCTIONS = "Нажмите кнопку, чтобы сменить клавишу (только A-Z).",
				INSTRUCTIONS_LINE1 = "Нажмите клавишу для привязки,",
				INSTRUCTIONS_LINE2 = "Backspace для удаления привязки.",
				ACTION_TOGGLE_UI = "Переключить интерфейс",
				ACTION_TOGGLE_INDICATORS = "Переключить индикаторы",
				NONE = "Нет",
			},
			CONFIG = {
				TITLE = "Настройки",
				HUD_BUTTON = "Кнопка на HUD",
				MAP_ICONS = "Значки на карте",
				MAP_ICONS_ALL = "Все",
				MAP_ICONS_VISIBLE = "Только видимые",
				MAP_ICONS_OFF = "Выкл",
				COORDINATES = "Координаты X/Z",
				CLICK_TO_TRAVEL = "Перемещение по клику",
				ON = "Вкл",
				OFF = "Выкл",
				DEBUG_BUTTON = "Отладка",
				KEYBINDS_DESC = "Окно: %s   Индикаторы: %s",
				HUD_BUTTON_DESC_ON = "Кнопка на экране открывает список",
				HUD_BUTTON_DESC_OFF = "Кнопки нет — используйте клавишу",
				MAP_ICONS_DESC_ALL = "Флажки всех точек на карте",
				MAP_ICONS_DESC_VISIBLE = "Скрытые точки не показываются на карте",
				MAP_ICONS_DESC_OFF = "Флажков на карте нет",
				COORDINATES_DESC_ON = "X/Z показаны в списке",
				COORDINATES_DESC_OFF = "Координаты не показываются",
				CLICK_TO_TRAVEL_DESC_ON = "Нажмите на флажок, чтобы дойти до точки",
				CLICK_TO_TRAVEL_DESC_OFF = "Нажатие на флажок ничего не делает",
				DEBUG_TITLE = "Отладочная информация",
				UWID_LABEL = "UWID:",
				WAYPOINT_COUNT_LABEL = "Координаты:",
			},
		},
	},
}