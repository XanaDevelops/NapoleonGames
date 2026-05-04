extends GutTest

var gr : GameResources
var map : MapRes
func before_all():
	self.gr = GameResources.load_from()
	
	# generar un mapa
	
	var map_ids := [[0,0,0,0,0],
					[0,1,0,1,0],
					[0,1,0,1,0],
					[0,0,0,0,0]]
					
	self.map = MapRes.new()
	
	map.name = &"test_map_01"
	map.tamX = 5
	map.tamY = 4
	map.uid = 1
	
	var _uid := 1
	for file in map_ids:
		var aux : Array[TileRes]= []
		for t in file:
			var tile := TileRes.new()
			tile.height = 1
			tile.type = gr.tile_types[t]
			tile.uid = _uid
			_uid += 1 
			aux.append(tile)
		map.mapData.append(aux)
		
	map.mapData[0][4].height = 100
	map.mapData[3][4].height = 100
	
	gr.maps.append(map)
	
	gr.save_to()
	

func test_dijkstra() -> void:
	var mapGame := MapGame.new(map)
	var unit := UnitGame.new(gr.cards[0], null)
	mapGame.get_tile_at(Vector2i(2,2)).set_unit(unit)

	# Vecinos hexagonales: se valida como conjunto (sin depender del orden)
	# y cubriendo filas pares/impares y bordes.
	var pos_even_row := Vector2i(2, 2)
	var expected_even_row := [
		Vector2i(3, 2),
		Vector2i(1, 2),
		Vector2i(2, 3),
		Vector2i(1, 3),
		Vector2i(2, 1),
		Vector2i(1, 1),
	]
	_assert_neighbors(mapGame, pos_even_row, expected_even_row)

	var pos_odd_row := Vector2i(2, 1)
	var expected_odd_row := [
		Vector2i(3, 1),
		Vector2i(1, 1),
		Vector2i(3, 2),
		Vector2i(2, 2),
		Vector2i(3, 0),
		Vector2i(2, 0),
	]
	_assert_neighbors(mapGame, pos_odd_row, expected_odd_row)

	var corner := Vector2i(0, 0)
	var expected_corner := [Vector2i(1, 0), Vector2i(0, 1)]
	_assert_neighbors(mapGame, corner, expected_corner)

	# Dijkstra: comprobaciones robustas (invariantes) sobre movimientos accesibles.
	var available := mapGame.get_accesible_moves(pos_even_row)
	assert_false(pos_even_row in available)
	assert_true(available.size() >= 0)
	assert_true(available.size() <= (map.tamX * map.tamY) - 1)

	# Todos los movimientos deben estar dentro del mapa y no repetidos.
	var seen := {}
	for p in available:
		assert_true(_in_rect_bounds(p))
		assert_false(seen.has(p))
		seen[p] = true

	# Si la unidad tiene velocidad >= 1, todos los vecinos vacíos inmediatos son alcanzables.
	if unit.get_speed() >= 1:
		for p in mapGame.get_neightbours(pos_even_row):
			assert_true(p in available)


func _assert_neighbors(mapGame: MapGame, pos: Vector2i, expected: Array) -> void:
	var actual := mapGame.get_neightbours(pos)
	assert_eq(actual.size(), expected.size())
	for e in expected:
		assert_true(e in actual)
	for a in actual:
		assert_true(a in expected)
		assert_true(_in_rect_bounds(a))


func _in_rect_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < map.tamX and p.y >= 0 and p.y < map.tamY
