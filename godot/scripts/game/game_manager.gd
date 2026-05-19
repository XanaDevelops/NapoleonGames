extends Node

@export var game_res: GameResources
@export var app_state := APP_STATE.MENU_HUB
@export var game_config: GameConfig

var turn_manager: TurnManager
signal phase_changed(phase: APP_STATE)
enum APP_STATE {
	MENU_HUB,
	IN_GAME,
}

## Indica si es servidor
var is_server := false

func _init() -> void:
	print(OS.get_cmdline_args())
	var cmd_args := OS.get_cmdline_args()
	if "--server" in cmd_args:
		is_server = true
		
	game_res = GameResources.load_from()
	#temporal
	#self.turn_manager= TurnManager.new()
	app_state = APP_STATE.MENU_HUB
	#phase_changed.emit(app_state)
	set_users()
	
func _ready() -> void:
	if is_server:
		_configure_server()
	else:
		_configure_client()

func _configure_server() -> void:
	if not Online.start_server():
		return

	print_rich("[color=yellow]SOMOS servidor[/color]")
	UiManager.cambiar_a_escena("server")
	
func _configure_client() -> void:
	if not Online.start_client():
		return
	print_rich("[color=yellow]SOMOS cliente[/color]")
	NetClient.handle_local_id_assignment.connect(func (pid: int):
		var ping_n := randi()
		print("Mi randi ", ping_n)
		PingPacket.create(pid, "Hola que tal? soy:" + str(pid) + "num: "+str(ping_n)).send(Online.server_peer)	
	)
	

func set_users() -> void:
	var gr := GameResources.load_from()
	if game_config == null:
		game_config = GameConfig.new()
	game_config.user_a = gr.users[0]
	game_config.user_b = gr.users[1]
	
## Placeholder
func start_game(playerA: UserRes, playerB:UserRes, map:MapRes,
	armyA: ArmyRes, armyB:ArmyRes, isOnline:= false, game_pid:= -1
	) -> void:
	game_config = GameConfig.new(playerA, playerB, map, armyA, armyB)
	if isOnline:
		if UserManager.usuario_actual == playerA:
			game_config.user_online = GameConfig.ONLINE_USER.USER_A
		elif UserManager.usuario_actual == playerB:
			game_config.user_online = GameConfig.ONLINE_USER.USER_B
		elif is_server:
			game_config.user_online = GameConfig.ONLINE_USER.SERVER
		else:
			push_error("Intentado iniciar una partida online sin el usuario actual!")
			return
	game_config.game_pid = game_pid
	app_state = APP_STATE.IN_GAME

	if !is_server:
		UiManager.cambiar_a_escena("juego")
	else:
		turn_manager = TurnManager.new()

# resetea la partida
func restart_current_game() -> void:
	if game_config == null:
		return
	var mapa_original = game_config.map_res
	start_game(game_config.user_a, game_config.user_b, mapa_original, game_config.army_a, game_config.army_b)
	
## Placeholder para obtener la info de configuración de una partida[br]
## Como puede ser los jugadores que se enfrentan, el mapa y ejercitos 
func get_game_config() -> GameConfig:
	return game_config
	

func get_game_resources() -> GameResources:
	return game_res
	
func get_turn_manager() -> TurnManager:
	return self.turn_manager
## Registra un TurnManager como el actual
## si hay que configurar signals y cosas de esas aquí
func register_turn_manager(tm: TurnManager) -> void:
	self.turn_manager = tm
