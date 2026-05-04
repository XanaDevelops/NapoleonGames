class_name TileGame
extends RuntimeResource

@export var _tileRes: TileRes

@export var _unit: UnitGame 

var _position: Vector2i

func _init(tileRes: TileRes, pos: Vector2i) -> void:
	self._tileRes = tileRes
	self._position = pos
	
## Devuelve la textura del tile, o de la tropa que contenga
func get_texture2D() -> Texture2D:
	return self._tileRes.type.texture
	
func set_unit(unit: UnitGame) -> void:
	assert(not (self._unit and unit), "[TileGame] se ha intentado asignar una unidad a una casilla ocupada")
	self._unit = unit
	if unit:
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
	
func get_position() -> Vector2i:
	return _position

func get_tile_name() -> String:
	return self._tileRes.type.name

func get_tile_desc() -> String:
	return self._tileRes.type.desc

func get_mods() -> Array[TileModRes]:
	return self._tileRes.type.mods
func get_tile_cost() -> int:
	return self._tileRes.type.cost

func get_owner_name() -> String:
	if self._unit._owner!=null:
		return self._unit._owner.name
	return " "
func get_unit_weight() -> int:
	return self._unit._cardRes.weight

func get_unit_portrait() -> Texture2D:
	return self._unit._cardRes.portrait

func get_speed() -> int:
	return self._unit._cardRes.speed
func get_dodge() -> int:
	return self._unit._cardRes.dodge

func get_currentHealth() -> int:
	return self._unit.hp

func get_currentMana() -> int:
	return self._unit.mana
	
func get_availableHabilities() -> Dictionary[HabilityRes, int] :
	return self._unit._habilities

func get_habilities() -> Array[HabilityRes]:
	return self._unit.get_all_habilities()

func get_resistances() -> Dictionary[AttackType, int]:
	return self._unit._cardRes.resistances

func get_AlterStates()-> Dictionary[AlterStateRes, int]:
	return self._unit._currentAlterStates
