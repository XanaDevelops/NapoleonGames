class_name UnitOverlay
extends Control

@onready var hp_bar = $HealthBar

var _unit: UnitGame = null
var _tile_map: TileMapLayer = null
var _coords: Vector2i

func setup(unit: UnitGame, coords: Vector2i, tile_map: TileMapLayer) -> void:
	_unit = unit
	_coords = coords
	_tile_map = tile_map
	
	hp_bar.init(unit.max_hp)
	hp_bar.update(unit.hp)
	
	unit.health_changed.connect(_on_health_changed)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_update_position()
	print("size of hp_bar", hp_bar.size)

func _on_health_changed(current: int) -> void:
	hp_bar.update(current)

func _update_position() -> void:
	var local_pos = _tile_map.map_to_local(_coords)
	position = local_pos - Vector2(hp_bar.size.x / 2.0, -25)
	

func update_coords(new_coords: Vector2i) -> void:
	_coords = new_coords
	_update_position()

func cleanup() -> void:
	if _unit != null and _unit.health_changed.is_connected(_on_health_changed):
		_unit.health_changed.disconnect(_on_health_changed)
	queue_free()

# En unit_overlay.gd
func set_exhausted(exhausted: bool) -> void:
	if exhausted:
		modulate = Color(0.4, 0.4, 0.4, 1.0)
	else:
		modulate = Color.WHITE
