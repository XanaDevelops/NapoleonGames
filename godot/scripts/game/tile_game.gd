class_name TileGame
extends Node

@export var _tileRes: TileRes

@export var _unit: UnitGame 

func _init(tileRes: TileRes) -> void:
	self._tileRes = tileRes
	
## Devuelve la textura del tile, o de la tropa que contenga
func get_texture2D() -> Texture2D:
	#if self._unit != null:
		#return self._unit.get_texture2D()
		
	return self._tileRes.type.texture
	
func get_unit_texture2D() -> Texture2D:
	if self._unit != null:
		return self._unit.get_texture2D()
	return null
	
func set_unit(unit: UnitGame) -> void:
	assert(!self._unit, "[TileGame] se ha intentado asignar una unidad a una casilla ocupada")
	self._unit = unit

func get_unit() -> UnitGame:
	return self._unit
func has_unit() -> bool:
	return self._unit != null
	
