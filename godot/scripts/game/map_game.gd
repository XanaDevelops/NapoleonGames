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

func get_valid_targets(hab: HabilityRes, pos: Vector2i, unit: UnitGame) -> Array[Vector2i]:

	if hab.objective == HabilityRes.HAB_DEST.SELF:
		return [pos]
	
	var in_range = get_cells_in_range(pos, hab.radius)
	match hab.objective:
		HabilityRes.HAB_DEST.SINGLE_ENEMY, HabilityRes.HAB_DEST.MULTI_ENEMY:
			return in_range.filter(func(c):
				var tile = get_tile_at(c)
				return tile.has_unit() and tile.get_unit()._owner != unit._owner
			)
			
		HabilityRes.HAB_DEST.SINGLE_ALLY, HabilityRes.HAB_DEST.MULTIPLE_ALLY:
			return in_range.filter(func(c):
				var tile = get_tile_at(c)
				
				return tile.has_unit() and tile.get_unit()._owner == unit._owner
			)
			
		HabilityRes.HAB_DEST.SINGLE_ANY, HabilityRes.HAB_DEST.MULTIPLE_ANY:
			return in_range.filter(func(c):
				return get_tile_at(c).has_unit()
			)
			
		HabilityRes.HAB_DEST.EVERYONE:
			in_range.append(pos)
			return in_range.filter(func(c):
				var tile = get_tile_at(c)
				return tile.has_unit() 
			)
	
	return []

func apply_hability(hab:HabilityRes, pos:Vector2i, targets:Array[Vector2i]) -> void:
	var user_tile = get_tile_at(pos)
	var unit = user_tile.get_unit()
	unit._currentMana-=hab.manaCost
	
	unit._habilities[hab]= hab.cooldown
	for target_pos in targets:
		var target_tile = get_tile_at(target_pos)
		if not target_tile.has_unit():
			continue
		var target_unit= target_tile.get_unit()
		if hab.stat!=null:
			_apply_stat_effect(hab, unit, target_unit, target_pos)
		
		for alter_state in hab.alter_states:
			target_unit._currentAlterStates[alter_state]= alter_state.duration
	

func _apply_stat_effect(hab: HabilityRes, src_unit:UnitGame, target_unit:UnitGame, target_pos: Vector2i):
	if hab.stat==null:
		return 
	var value: float= hab.value
		
	match hab.stat.name:
			StatData.DEFENSE:
				var id_dead= target_unit.recieve_attack(int(value), hab.attackType)
				if id_dead:
					target_unit.kill()
					get_tile_at(target_pos).set_unit(null)
			StatData.SPEED:
				push_warning("_apply_stat_effect: speed debe modificarse via alter_states")

				
				
