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
				temp.append(TileGame.new(t, Vector2i(j,i)))
			_map.append(temp)

func get_tile_at(pos : Vector2i) -> TileGame:
	return self._map[pos.y][pos.x]

func get_neightbours(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []

	# En TileMaps hexagonales con offset horizontal, las filas alternan el desplazamiento;
	# por tanto, la paridad relevante es la de 'y' (fila), no la de 'x'.
	for candidate in _get_clockwise_neighbors(pos):
		if _is_in_map_bounds(candidate):
			neighbors.append(candidate)

	return neighbors
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
func get_units_range(pos: Vector2i, range: int, filter: int) -> Array[Vector2i]:
	var ret_pos : Array[Vector2i] = []
	var tile := get_tile_at(pos)
	if !tile.has_unit():
		return ret_pos
	
	var unit := tile.get_unit()
	var distances := _calculate_distances(pos, null)
	
	for key in distances:
		if distances[key] <= range and get_tile_at(key).has_unit():
			if key == pos and HabilityRes.inflicts_self(filter):
				ret_pos.append(key)
				continue
				
			var same_own := get_tile_at(key).get_unit()._owner == unit._owner
			if      (same_own and HabilityRes.inflicts_ally(filter)) or \
				(not same_own) and HabilityRes.inflicts_enemy(filter):
				ret_pos.append(key)
				
	
	return ret_pos
	
	
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
			if not get_tile_at(key).has_unit():
				ret_pos.append(key)
		
	return ret_pos
	
## Good ol' Dijkstra
func _calculate_distances(pos: Vector2i, unit: UnitGame) -> Dictionary[Vector2i, int]:
	const MAX_INT := 9223372036854775806
	
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
	
func get_cells_in_range(pos: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var visited: Dictionary[Vector2i, int] = {pos: 0} #BFS
	var queue: Array[Vector2i] = [pos]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_dist = visited[current]
		
		if current_dist >= radius:
			continue
		
		for neighbour in get_neightbours(current):
			if not visited.has(neighbour):
				visited[neighbour] = current_dist + 1
				queue.append(neighbour)
	
	# Exclude pos 
	for cell in visited.keys():
		if cell != pos:
			result.append(cell)
	
	return result

				
func calculate_deployment(player_id: int, size: int, start_tile: Vector2i) -> Dictionary:
	var result := {"tiles": [] as Array[Vector2i], "is_valid": true}
	var ideal_shape: Array[Vector2i] = []
	var queue: Array[Vector2i] = [start_tile]
	var visited: Dictionary = {start_tile: true}

	var deploy_height := _mapRes.deployHeight
	var limit_up := (deploy_height - 1) / 2
	var limit_down := deploy_height / 2
	var min_allowed_y := start_tile.y - limit_up
	var max_allowed_y := start_tile.y + limit_down

	while ideal_shape.size() < size and not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		ideal_shape.append(current)
		
		for neighbor in _get_clockwise_neighbors(current):
			if not visited.has(neighbor):
				visited[neighbor] = true
				if neighbor.y >= min_allowed_y and neighbor.y <= max_allowed_y:
					queue.append(neighbor)

	for pos in ideal_shape:
		result["tiles"].append(pos)
		
		if not _is_in_map_bounds(pos) or not _is_in_deployment_zone(pos, player_id) or get_tile_at(pos).has_unit():
			result["is_valid"] = false

	if result["tiles"].size() < size:
		result["is_valid"] = false
		
	return result

func _get_clockwise_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var is_shifted_right: bool = (absi(pos.y) % 2 == 1)
	var left_x := pos.x if is_shifted_right else pos.x - 1
	var right_x := pos.x + 1 if is_shifted_right else pos.x
	
	return [
		Vector2i(pos.x + 1, pos.y),
		Vector2i(pos.x - 1, pos.y),
		Vector2i(right_x, pos.y + 1),
		Vector2i(left_x, pos.y + 1),
		Vector2i(right_x, pos.y - 1),
		Vector2i(left_x, pos.y - 1)
	]

func _is_in_map_bounds(pos: Vector2i) -> bool:
	return pos.y >= 0 and pos.y < _map.size() and pos.x >= 0 and pos.x < _map[pos.y].size()

func _is_in_deployment_zone(pos: Vector2i, player_id: int) -> bool:
	var zone_thickness := _mapRes.deployHeight
	return pos.y >= (_map.size() - zone_thickness) if player_id == 0 else pos.y < zone_thickness

func get_deployment_zone_tiles(player_id: int) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var zone_thickness := _mapRes.deployHeight
	var start_y: int = maxi(0, _map.size() - zone_thickness) if player_id == 0 else 0
	var end_y: int = _map.size() if player_id == 0 else mini(_map.size(), zone_thickness)

	for y in range(start_y, end_y):
		for x in range(_map[y].size()):
			tiles.append(Vector2i(x, y))
			
	return tiles

func place_unit(unit: UnitGame, pos: Vector2i) -> bool:
	if not _is_in_map_bounds(pos):
		return false
		
	var tile: TileGame = get_tile_at(pos)
	if tile.has_unit():
		return false
		
	tile.set_unit(unit)
	unit._tile = tile 
	#conectar con el turn_manager
	var tm = GameManager.get_turn_manager()
	if tm != null and not tm.tick_turn.is_connected(unit.advance_turn):
		tm.tick_turn.connect(unit.advance_turn)
	
	return true
