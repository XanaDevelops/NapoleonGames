class_name TurnAction
extends GameResource


enum ACTION {
	MOVEMENT, #movimiento
	ACTIVE,   #uso de habilidad activa
	PASSIVE,   #activacion de habilidad pasiva
	ALTER_STATE, #activación de un estado alterado
	DEPLOYMENT, 
	PASS_TURN
}

var player: UserGame
var action: ACTION
var unit: UnitGame
var start: Vector2i
var end: Vector2i
var hability: HabilityRes
var dest: Array[Vector2i]
var deploy_pos: Vector2i


func _init() -> void:
	pass
