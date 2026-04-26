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
	if y%2 == 1:
		x += 1
	else:
		x -= 1
		
	if x >= 0 and x < _map[0].size():
		if y-1 >= 0:
			neight.append(Vector2i(x, y-1))
		if y+1 < _map.size():
			neight.append(Vector2i(x, y+1))
	
	return neight
## Mueve una unidad de 'start' a 'end'
## Ten en cuenta que esto no comprueba si la casilla es alcanzable
## De eso TurnManager (TODO)
func move_unit(start: Vector2i, end: Vector2i) -> void:
	assert(self._map[start.y][start.x].has_unit(), "Casilla vacia")
	assert(!self._map[end.y][end.x].has_unit(), "Casilla ocupada")
	
	var unit := get_tile_at(start).get_unit()
	get_tile_at(start).set_unit(null)
	get_tile_at(end).set_unit(unit)
	
## Devuelve las posiciones con tropas dentro del rango
func get_units_range(pos: Vector2i, range: int, filter:= HabilityRes.HAB_DEST.EVERYONE) -> Array[Vector2i]:
	var ret_pos : Array[Vector2i] = []
	var tile := get_tile_at(pos)
	if !tile.has_unit():
		return ret_pos
	
	var unit := tile.get_unit()
	var distances := _calculate_distances(pos, null)
	
	for key in distances:
		if distances[key] <= range and get_tile_at(key).has_unit():
			var same_own := get_tile_at(key).get_unit()._owner == unit._owner
			if same_own and HabilityRes.inflicts_ally(filter) or \
				not same_own and HabilityRes.inflicts_enemy(filter):
				ret_pos.append(key)
	
	return ret_pos
	
	
## Devuelve las posiciones de casillas accesibles para la unidad en 'pos'
## devuelve [] si no hay unidad
## En godot/scripts/game/map_game.gd
func get_accesible_moves(pos: Vector2i) -> Array[Vector2i]:
	var ret_pos : Array[Vector2i] = []
	var tile := get_tile_at(pos)
	
	if !tile.has_unit():
		return ret_pos
	
	var unit := tile.get_unit()
	var distances := _calculate_distances(pos, unit)
	
	for key in distances:
		if distances[key] <= unit.get_speed() and key != pos:
			if not get_tile_at(key).has_unit():
				ret_pos.append(key)
		
	return ret_pos
	
## Good ol' Dijkstra
func _calculate_distances(pos: Vector2i, unit: UnitGame) -> Dictionary[Vector2i, int]:
	const MAX_INT := 9223372036854775807
	
	var distances : Dictionary[Vector2i, int] = {pos: 0}
	# No existen genericos, no tipas la lambda
	var queue : PriorityQueue = PriorityQueue.new(false, [], func(x): return x.values()[0])
	queue.insert({pos: 0})
	
	while queue.size() > 0:
		var elem : Dictionary = queue.head()
		queue.delete_node(elem)
		var _pos : Vector2i = elem.keys()[0]
		var _dist : int= elem[_pos]
		
		if _dist > distances.get(_pos, MAX_INT):
			continue
		
		for neight in get_neightbours(_pos):
			var _cost : int
			if unit:
				_cost = get_tile_at(neight).get_cost(unit)
				# penalización altura
				_cost += get_tile_at(_pos).get_height_penalty(get_tile_at(neight))
			else:
				_cost = 1
			if distances.get(_pos) + _cost < distances.get(neight, MAX_INT):
				distances.set(neight, distances.get(_pos) + _cost)
				queue.insert({neight: distances.get(_pos) + _cost})
				
	return distances
	
	
	
