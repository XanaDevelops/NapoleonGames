class_name TurnManager
extends Node

@onready var visualizador : mapVisualizer = $IngameMap/mapVisualizer
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
	var dest : Array[Vector2i]
	
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
		#unit.has_moved_this_turn = true
		visualizador.plot_unit_moved(start, end)
		
		var action = TurnAction.new()
		action.player = unit._owner
		action.action = TurnAction.ACTION.MOVEMENT
		action.start = start
		action.end = end
		register_turn(action)
	else:
		print("Acción denegada: No es el turno del dueño de esta unidad")


func _on_unit_hability_use(tile: Vector2i, objective: Vector2i, hability: HabilityRes) -> void:
	var map : MapGame = visualizador.map
	var unit_source := map.get_tile_at(tile).get_unit()
	if unit_source.has_hability_this_turn:
		print("La unidad ya ha usado una habilidad activa!")
		return
		
	if unit_source._owner != get_current_user():
		print("Acción denegada: No es el turno del dueño de esta unidad")
		return
		
	var _dests : Array[UnitGame] = []
	var dest_pos : Array[Vector2i]
	# Si la habilidad es de objetivo unico, este se ha seleccionado
	# con anterioridad
	if HabilityRes.inflicts_single(hability.objective):
		_dests.append(map.get_tile_at(objective).get_unit())
		dest_pos.append(objective)
	else:
		# Si no obtiene las unidades a rango
		dest_pos = map.get_units_range(tile, hability.radius, hability.objective)
		dest_pos.map(
			func (x: Vector2i): _dests.append(map.get_tile_at(x).get_unit())
		)
	var res := unit_source.use_hability(hability, _dests)
	if not res:
		print("No se cumple las condiciones para usar esta habilidad!")
		return
		
	var action := TurnAction.new()
	if hability.isPassive:
		action.action = TurnAction.ACTION.PASSIVE
	else:
		action.action = TurnAction.ACTION.ACTIVE
	action.action = TurnAction.ACTION.ACTIVE
	action.player = unit_source._owner
	action.unit = unit_source
	action.start = tile
	action.end = tile
	action.dest = dest_pos
	
	register_turn(action)
		
