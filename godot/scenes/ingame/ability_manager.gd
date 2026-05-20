class_name HabilityManager
extends Node


signal targets_highlighted(targets: Array[Vector2i])
signal confirm_requested(hab: HabilityRes, targets: Array[Vector2i], unit: UnitGame)
signal hability_applied(hab: HabilityRes, targets: Array[Vector2i])
signal cancelled()


enum Phase {
	IDLE,
	SELECTING_TARGET,
	CONFIRM_DIALOG,
}

var _phase:           Phase        = Phase.IDLE
var _pending_hab:     HabilityRes  = null
var _pending_targets: Array[Vector2i] = []
var _caster_coords:   Vector2i     = Vector2i(-1, -1)
var _caster_tile:     TileGame     = null

func request(hab: HabilityRes, coords: Vector2i, tile: TileGame) -> bool:
	if _pending_hab != null:
		cancel()

var tm := GameManager.get_turn_manager()
	var map := tm.get_map()
	
	if map == null:
		return false
		
	var unit := tile.get_unit()
	

	if unit == null or unit._owner != tm.get_current_user():
		print("Acción denegada: No es el turno de esta unidad.")
		return false
		

	var targets := map.get_units_range(coords, hab.radius, hab.objective)
  
	if targets.is_empty():
		push_warning("No hay objetivos válidos para '%s'" % hab.name)
		return false

	_pending_hab   = hab
	_caster_coords = coords
	_caster_tile   = tile

	targets_highlighted.emit(targets)

	if hab._inflicts_single(hab.objective):
		_phase = Phase.SELECTING_TARGET
	else:
		_pending_targets = targets
		_transition_to_confirm()

	return true


func try_select_target(coords: Vector2i) -> bool:
	if _phase != Phase.SELECTING_TARGET:
		return false

	var tm := GameManager.get_turn_manager()
	var map := tm.get_map()
	if map == null:
		cancel()
		return false
	var valid := map.get_units_range(_caster_coords, _pending_hab.radius, _pending_hab.objective)
	if coords not in valid:
		cancel()
		return false

	_pending_targets = [coords]
	_transition_to_confirm()
	return true


func confirm() -> void:
	if _phase != Phase.CONFIRM_DIALOG:
		return
	GameManager.get_turn_manager()._on_unit_hability_use(_caster_coords, _pending_targets, _pending_hab)
	
	var hab     := _pending_hab
	var targets := _pending_targets.duplicate()
	_reset()
	hability_applied.emit(hab, targets)


## Cancelar el flujo en cualquier fase.
func cancel() -> void:
	_reset()
	cancelled.emit()


func is_active() -> bool:
	return _phase != Phase.IDLE


func _transition_to_confirm() -> void:
	_phase = Phase.CONFIRM_DIALOG
	confirm_requested.emit(_pending_hab, _pending_targets, _caster_tile.get_unit())


func _reset() -> void:
	_phase           = Phase.IDLE
	_pending_hab     = null
	_pending_targets = []
	_caster_coords   = Vector2i(-1, -1)
	_caster_tile     = null
