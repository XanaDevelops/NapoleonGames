class_name TurnManager
extends Node

## Clase placeholder que representa una acion de un turno
class TurnAction extends GameResource:
	enum ACTION {
		MOVEMENT, #movimiento
		ACTIVE,   #uso de habilidad activa
		PASSIVE   #activación de habilidad pasiva
	}
	var player: UserRes
	var action : ACTION
	var unit : UnitGame
	var start : Vector2i
	var end : Vector2i
	var hability : HabilityRes
	
	func _init() -> void:
		pass
		
			
@export var turns : Array[TurnAction] = []
var turn_order : Array[UserRes] = []
var turn_number := 0

## Avanza el turno, pasandolo al siguiente jugador
func advance_turn() -> void:
	var user : UserRes = turn_order[turn_number % turn_order.size()]
	print("Turno de ", user.username)
	turn_number += 1
	
	tick_turn.emit()
	
func get_current_user() -> UserRes:
	return turn_order[turn_number % turn_order.size()]

## Placeholder para 
func register_turn(turn: TurnAction) -> bool:
	
	turns.append(turn)
	return true

signal tick_turn
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
