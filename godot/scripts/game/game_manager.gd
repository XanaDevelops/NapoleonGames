extends Node

@export var _user_a: UserRes
@export var _user_b: UserRes
@export var _gameMap: MapRes
@export var _army_a : ArmyRes
@export var _army_b : ArmyRes

@export var _gameRes: GameResources



enum APP_STATE {
	MENU_HUB,
	IN_GAME,
}
@export var _app_state := APP_STATE.MENU_HUB

func _ready() -> void:
	_gameRes = GameResources.load_from()
	


## Placeholder
func start_game(playerA: UserRes, playerB:UserRes, map:MapRes, armyA: ArmyRes, armyB:ArmyRes) -> void:
	print("iniciamos partida")
	print("playerA: ", playerA.username)
	print("playerB: ", playerB.username)
	self._user_a = playerA
	self._user_b = playerB
	self._gameMap = map
	self._army_a = armyA
	self._army_b = armyB
	

	# considerar usar enums
	UiManager.cambiar_a_escena("juego")
	
	_app_state = APP_STATE.IN_GAME
	
	
## Placeholder para obtener la info de configuración de una partida[br]
## Como puede ser los jugadores que se enfrentan, el mapa y ejercitos 
func get_game_config() -> void:
	pass
	
## Placeholder 
func _get_mapRes() -> MapRes:
	return self._gameMap._mapRes
	
func get_map() -> MapRes:
	return self._gameMap
	
func get_game_resources() -> GameResources:
	return self._gameRes
	
