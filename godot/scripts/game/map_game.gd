class_name MapGame
extends Node

@export var _mapRes: MapRes

var _map: Array[Array] = []

func _init(mapRes: MapRes) -> void:
	self._mapRes = mapRes
	for i in range(mapRes.mapData.size()):
			var row = mapRes.mapData[i]
			var temp: Array = []
			for j in range(row.size()):
				var t = row[j]
				temp.append(TileGame.new(t))
			_map.append(temp)

func get_tile_at(x:int, y:int) -> TileGame:
		return self._map[x][y]
