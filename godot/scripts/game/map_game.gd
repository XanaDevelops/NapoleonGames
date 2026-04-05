class_name MapGame
extends RuntimeResource

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

func get_tile_at(pos : Vector2i) -> TileGame:
	return self._map[pos.y][pos.x]

func get_neightbours(pos: Vector2i) -> Array[Vector2i]:
	var x := pos.x
	var y := pos.y
	
	var neight : Array[Vector2i] = []
	# los laterales son comunes
	if x-1 >= 0:
		neight.append(Vector2i(x-1, y))
	if y-1 >= 0:
		neight.append(Vector2i(x, y-1))
	if x+1 < _map[y].size():
		neight.append(Vector2i(x+1, y))
	if y+1 < _map.size():
		neight.append(Vector2i(x, y+1))
	
	# No existen arrays hexagonales, por lo que segun la paridad de la posicion
	# se calculan unos vecinos u otros
	if x%2 == 1:
		y += 1
	else:
		y -= 1
		
	if y >= 0 and y < _map.size():
		if x-1 >= 0:
			neight.append(Vector2i(x-1, y))
		if x+1 < _map[y].size():
			neight.append(Vector2i(x+1, y))
	
	return neight
## Mueve una unidad de 'start' a 'end'
## Ten en cuenta que esto no comprueba si la casilla es alcanzable
## De eso TurnManager (TODO)
func move_unit(start: Vector2i, end: Vector2i) -> void:
	assert(self._map[start.y][start.x].has_unit(), "Casilla vacia")
	assert(!self._map[end.y][end.y].has_unit(), "Casilla ocupada")
	
	var unit := get_tile_at(start).get_unit()
	get_tile_at(start).set_unit(null)
	get_tile_at(end).set_unit(unit)
	
## Devuelve las posiciones de casillas accesibles para la unidad en 'pos'
## devuelve [] si no hay unidad
func get_accesible_moves(pos: Vector2i) -> Array[Vector2i]:
	var ret_pos : Array[Vector2i] = []
	var tile := get_tile_at(pos)
	if !tile.has_unit():
		return ret_pos
	
	var unit := tile.get_unit()
	
	var distances := _calculate_distances(pos, unit)
	
	for key in distances:
		if distances[key] <= unit.get_speed() and key != pos:
			ret_pos.append(key)
		
	return ret_pos
	
func _calculate_distances(pos: Vector2i, unit: UnitGame) -> Dictionary[Vector2i, int]:
	var distances : Dictionary[Vector2i, int] = {pos: 0}
	# No existen genericos, no tipas la lambda
	var queue : PriorityQueue = PriorityQueue.new(false, [], func(x): return x.values()[0])
	queue.insert({pos: 0})
	
	while queue.size() > 0:
		var elem : Dictionary = queue.head()
		queue.delete_node(elem)
		var _pos : Vector2i = elem.keys()[0]
		var _dist : int= elem[_pos]
		
		if _dist > distances.get(_pos, 9223372036854775807):
			continue
		
		for neight in get_neightbours(_pos):
			var _cost := get_tile_at(neight).get_cost(unit)
			# penalización altura
			_cost += get_tile_at(_pos).get_height_penalty(get_tile_at(neight))
			if distances.get(_pos) + _cost < distances.get(neight, 9223372036854775807):
				distances.set(neight, distances.get(_pos) + _cost)
				queue.insert({neight: distances.get(_pos) + _cost})
				
	return distances
	
	
	
