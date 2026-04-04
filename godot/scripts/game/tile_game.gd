class_name TileGame
extends RuntimeResource

@export var _tileRes: TileRes

@export var _unit: UnitGame 

func _init(tileRes: TileRes) -> void:
	self._tileRes = tileRes
	
## Devuelve la textura del tile, o de la tropa que contenga
func get_texture2D() -> Texture2D:
	return self._tileRes.type.texture
	
func set_unit(unit: UnitGame) -> void:
	assert(!self._unit, "[TileGame] se ha intentado asignar una unidad a una casilla ocupada")
	self._unit = unit
	
func get_unit() -> UnitGame:
	return self._unit
func has_unit() -> bool:
	return self._unit != null
	
func get_cost(unit: UnitGame) -> int:
	return _tileRes.get_cost(unit._cardRes)
	
