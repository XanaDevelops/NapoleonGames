@abstract
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
## duplicate no funciona si _init(..args), en teoria lo que nos hace falta no cambia
var unit: UnitGame



func _init() -> void:
	pass
