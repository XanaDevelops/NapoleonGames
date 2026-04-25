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
	if unit == null:
		# Si le pasamos 'null', significa que estamos vaciando la casilla
		self._unit = null
	else:
		# Si le pasamos una unidad, comprobamos que esté vacía y la asignamos
		assert(!self._unit, "[TileGame] se ha intentado asignar una unidad a una casilla ocupada")
		self._unit = unit
		self._unit._tile = self
	
func get_unit() -> UnitGame:
	return self._unit
func has_unit() -> bool:
	return self._unit != null
	
func get_cost(unit: UnitGame) -> int:
	return _tileRes.get_cost(unit._cardRes)
	
func get_height_penalty(tile: TileGame) -> int:
	return absi(self._tileRes.height - tile._tileRes.height) / 5
	
func get_height() -> int:
	return _tileRes.height

func get_info() -> Dictionary:
	return {
		"tile_name": _tileRes.type.name,
		"tile_desc": _tileRes.type.desc,
		"height": _tileRes.height,
		"mods": _tileRes.type.mods,
		"move_cost": _tileRes.type.cost,
		"texture": _tileRes.type.texture
	}
func get_unit_info() -> Dictionary:
	return{
		"card_name": _unit._cardRes.name,
		"card_desc": _unit._cardRes.desc,
		"card_currentHealth": _unit._currentHealth, 
		"card_currentMana": _unit._currentMana,
		"card_owner": _unit._owner,
		"card_speed": _unit._cardRes.speed,
		"card_dodge": _unit._cardRes.dodge,
		"card_portrait": _unit._cardRes.portrait,
		"card_resistances":_unit._cardRes.resistances,
		"card_available_habilities":_unit._habilities,
		"card_habilities": _unit._cardRes.habilities,
		"card_currentAlterStates": _unit._currentAlterStates,
		"card_weight": _unit._cardRes.weight
		
		
	}
