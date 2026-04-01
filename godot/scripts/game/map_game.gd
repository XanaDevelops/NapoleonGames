class_name MapGame
extends Node

@export var _mapRes: MapRes


var _map: Array[Array] = []

func _init(mapRes: MapRes) -> void:
	self._mapRes = mapRes
	
	for row in _mapRes.mapData:
		var temp: Array[TileRes] = []
		for t in row:
			temp.append(TileGame.new(t))
		_map.append(temp)

func get_tile_at(pos : Vector2i) -> TileGame:
	return self._map[pos.y][pos.x]

func move_unit(start: Vector2i, end: Vector2i) -> bool:
	assert(self._map[start.y][start.x].has_unit(), "Casilla vacia")
	assert(!self._map[end.y][end.y].has_unit(), "Casilla ocupada")
	
	
	
