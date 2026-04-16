class_name TurnManager
extends Node

@onready var visualizador = $IngameMap/mapVisualizer
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
	visualizador.movement_requested.connect(_on_unit_movement_requested)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_unit_movement_requested(start: Vector2i, end: Vector2i) -> void:
	var map_logic = visualizador.map 
	var unit = map_logic.get_tile_at(start).get_unit()
	if unit.has_moved_this_turn:
		print("La unidad ya se ha movido")
		return
		
	if unit._owner == get_current_user():
	
		map_logic.move_unit(start, end)
		unit.has_moved_this_turn = true
		visualizador.plot_unit_moved(start, end)
		
		var action = TurnAction.new()
		action.player = unit._owner
		action.action = TurnAction.ACTION.MOVEMENT
		action.start = start
		action.end = end
		register_turn(action)
	else:
		print("Acción denegada: No es el turno del dueño de esta unidad")
