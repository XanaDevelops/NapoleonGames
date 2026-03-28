class_name GameManager
extends Node


@export var _gameMap: MapGame

enum APP_STATE {
	MENU_HUB,
	IN_GAME,
}

## Placeholder
func start_game(playerA: UserRes, playerB:UserRes, map:MapRes, armyA: ArmyRes, armyB:ArmyRes) -> void:
	pass
	
## Placeholder para obtener la info de configuración de una partida[br]
## Como puede ser los jugadores que se enfrentan, el mapa y ejercitos 
func get_game_config() -> void:
	pass
	
## Placeholder 
func _get_mapRes() -> MapRes:
	return self._gameMap._mapRes
	
func get_map() -> MapGame:
	return self._gameMap
