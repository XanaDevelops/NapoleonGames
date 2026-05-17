class_name TurnAction
extends GameResource


enum ACTION {
	MOVEMENT, #movimiento
	ACTIVE,   #uso de habilidad activa
	PASSIVE,   #activacion de habilidad pasiva
	DEPLOYMENT
}

var player: UserRes
var action: ACTION
var unit: UnitGame
var start: Vector2i
var end: Vector2i
var hability: HabilityRes
var dest: Array[Vector2i]
var deploy_pos: Vector2i


func _init() -> void:
	pass
