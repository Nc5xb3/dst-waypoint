WAYPOINT = {
	NAME = "Waypoint Mod",
	AUTHOR = "Nc5xb3",
	UI = {
		HUD = {
			TOOLTIP = "Mostrar/ocultar Waypoints"
		},
		CONTROLLER = {
			TOGGLE_INDICATORS = "Indicadores de waypoint",
			ADD_REMOVE = "Adicionar/remover waypoint",
		},
		MENU = {
			TITLE = "- Waypoint -"
		},
		BUTTON = {
			TOGGLE_EDITMODE = "Alternar modo de edição",
			CONFIGURATIONS = "Configurações",
			TOGGLE_INDICATORS = "Mostrar/ocultar indicadores",
			TOGGLE_MOVEMENT_PREDICTION = "Alternar previsão de movimento",

			ADD = "Adicionar waypoint",

			PREV = "Página anterior",
			NEXT = "Próxima página",

			TRAVEL = "Viajar",

			MOVE_UP = "Subir",
			MOVE_DOWN = "Descer",
			TOGGLE_VISIBILITY = "Alternar visibilidade",
			EDIT = "Editar",

			CLOSE = "Fechar",
			EDIT_KEYBINDS = "Teclas",
		},
		INDICATOR = {
			BUTTON = {
				PREFIX_TRAVELTO = "Viajar para ",
				SUFFIX_TRAVELTO = ""
			},
		},
		DIALOG = {
			OPTION = {
				SAVE = "Salvar",
				CANCEL = "Cancelar",
				OKAY = "OK",
				DELETE = "Excluir",
				CLOSE = "Fechar",
			},
			EDIT = {
				TITLE = "Editar waypoint",
				NAME = "Name",
				COORDINATES = "Coordenadas",
				COLOUR = "Cor",
				RANDOMIZE = "Aleatória",
			},
			DELETE_CONFIRM = {
				TITLE = "Excluir waypoint?",
				MESSAGE = "\"%s\" será excluído. Isso não pode ser desfeito.",
			},
			MP = {
				TITLE = "Informação",
				MESSAGE1 = "A compensação de lag NÃO está em modo preditivo,",
				MESSAGE2 = "ou seja, a 'previsão de movimento' está desativada!",
				MESSAGE3 = "Por isso, não é possível viajar até um waypoint.",
				MESSAGE4 = "Agora há um botão visível para alternar",
				MESSAGE5 = "a previsão de movimento e poder viajar.",
			},
			KEYBINDS = {
				TITLE = "Teclas",
				CAPTURE_TITLE = "Pressione uma tecla",
				INSTRUCTIONS = "Clique em um botão para mudar a tecla (apenas A-Z).",
				INSTRUCTIONS_LINE1 = "Pressione uma tecla para atribuir,",
				INSTRUCTIONS_LINE2 = "ou Backspace para remover.",
				ACTION_TOGGLE_UI = "Mostrar/ocultar a interface",
				ACTION_TOGGLE_INDICATORS = "Mostrar/ocultar indicadores",
				NONE = "Nenhuma",
			},
			INDICATOR_AREA = {
				TITLE = "Área dos indicadores",
				SHAPE = "Forma",
				SIZE = "Tamanho",
				SHAPE_RECTANGLE = "Retângulo",
				SHAPE_ELLIPSE = "Oval",
				SHAPE_CIRCLE = "Círculo",
				NAMES = "Nomes",
				NAMES_ALWAYS = "Sempre",
				NAMES_HOVER = "Ao passar",
				PREVIEW_NOTE = "Pontilhado: onde ficam os indicadores",
			},
			CONFIG = {
				TITLE = "Configurações",
				HUD_BUTTON = "Botão na HUD",
				MAP_ICONS = "Ícones no mapa",
				MAP_ICONS_ALL = "Todos",
				MAP_ICONS_VISIBLE = "Só visíveis",
				MAP_ICONS_OFF = "Desligado",
				COORDINATES = "Coordenadas",
				CLICK_TO_TRAVEL = "Clique para viajar",
				ON = "Ligado",
				OFF = "Desligado",
				DEBUG_BUTTON = "Depuração",
				KEYBINDS_DESC = "Janela: %s   Indicadores: %s",
				HUD_BUTTON_DESC_ON = "Um botão na tela abre a lista",
				HUD_BUTTON_DESC_OFF = "Sem botão na tela; use sua tecla",
				MAP_ICONS_DESC_ALL = "Todos os waypoints têm bandeira no mapa",
				MAP_ICONS_DESC_VISIBLE = "Waypoints escondidos ficam fora do mapa",
				MAP_ICONS_DESC_OFF = "Nenhuma bandeira no mapa",
				COORDINATES_DESC_ON = "X/Z aparecem na lista",
				COORDINATES_DESC_OFF = "Coordenadas não são mostradas",
				CLICK_TO_TRAVEL_DESC_ON = "Clique na bandeira para andar até lá",
				CLICK_TO_TRAVEL_DESC_OFF = "Clicar na bandeira não faz nada",
				INDICATOR_AREA = "Área dos indicadores",
				INDICATOR_AREA_DESC = "%s, %s%% da tela",
				DEBUG_TITLE = "Informações de depuração",
				UWID_LABEL = "UWID:",
				WAYPOINT_COUNT_LABEL = "Waypoints:",
			},
		},
	},
}