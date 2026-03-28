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

func get_tile_at(x:int, y:int) -> TileGame:
	return self._map[y][x]
