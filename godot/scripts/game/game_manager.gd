extends Node

@export var _user_a: UserRes
@export var _user_b: UserRes
@export var _army_a : ArmyRes
@export var _army_b : ArmyRes
@export var _gameMap: MapGame
@export var _gameRes: GameResources

var turn_manager: TurnManager
signal phase_changed(phase: APP_STATE)
enum APP_STATE {
	MENU_HUB,
	DEPLOYMENT,
	IN_GAME,
}
@export var _app_state := APP_STATE.MENU_HUB

## Indica si es servidor
var is_server := false

func _init() -> void:
	print(OS.get_cmdline_args())
	var cmd_args := OS.get_cmdline_args()
	if "--server" in cmd_args:
		is_server = true
		
	_gameRes = GameResources.load_from()
	#temporal
	#self.turn_manager= TurnManager.new()
	_app_state = APP_STATE.MENU_HUB
	#phase_changed.emit(_app_state)
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
	self._user_a = gr.users[0]
	self._user_b = gr.users[1]
	
## Placeholder
func start_game(playerA: UserRes, playerB:UserRes, map:MapRes, armyA: ArmyRes, armyB:ArmyRes) -> void:

	self._user_a = playerA
	self._user_b = playerB
	self._gameMap = MapGame.new(map)
	self._army_a = armyA
	self._army_b = armyB

	#_app_state = APP_STATE.IN_GAME
	_app_state = APP_STATE.DEPLOYMENT

	UiManager.cambiar_a_escena("juego")
	

# resetea la partida
func restart_current_game() -> void:
	var mapa_original = self._gameMap._mapRes
	start_game(self._user_a, self._user_b, mapa_original, self._army_a, self._army_b)
	
## Placeholder para obtener la info de configuración de una partida[br]
## Como puede ser los jugadores que se enfrentan, el mapa y ejercitos 
func get_game_config() -> void:
	pass
	

## Placeholder 
func _get_mapRes() -> MapRes:
	return self._gameMap._mapRes
	
func get_map() -> MapGame:
	return self._gameMap
	
func get_game_resources() -> GameResources:
	return self._gameRes

func set_map(map_game:MapGame) -> void:
	self._gameMap= map_game
	
func get_turn_manager() -> TurnManager:
	return self.turn_manager
## Registra un TurnManager como el actual
## si hay que configurar signals y cosas de esas aquí
func register_turn_manager(tm: TurnManager) -> void:
	self.turn_manager = tm

func get_current_phase() -> String:
	match _app_state:
		APP_STATE.DEPLOYMENT:
			return "Despliegue"
		APP_STATE.IN_GAME: 
			return "Combate"
	return ""
