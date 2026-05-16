extends GutTest

var gr : GameResources
var map : MapRes
func before_all():
	self.gr = GameResources.load_from("res://test/test_res/all_test_resources.tres")
	
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
	
	gr.save_to("res://test/test_res/all_test_resources.tres")
	

func test_dijkstra() -> void:
	var mapGame := MapGame.new(map)
	var unit := UnitGame.new(gr.cards[0], null)
	var pos_even := Vector2i(2, 2) # y par
	mapGame.get_tile_at(pos_even).set_unit(unit)

	# Vecinos esperados para y par (layout offset horizontal)
	var expected_even := [
		Vector2i(3, 2),
		Vector2i(1, 2),
		Vector2i(2, 3),
		Vector2i(1, 3),
		Vector2i(2, 1),
		Vector2i(1, 1),
	]
	var actual_even := mapGame.get_neightbours(pos_even)
	assert_eq(actual_even.size(), expected_even.size())
	for p in expected_even:
		assert_true(p in actual_even)
	for p in actual_even:
		assert_true(p in expected_even)

	# Vecinos esperados para y impar (otra paridad)
	var pos_odd := Vector2i(2, 1) # y impar
	var expected_odd := [
		Vector2i(3, 1),
		Vector2i(1, 1),
		Vector2i(3, 2),
		Vector2i(2, 2),
		Vector2i(3, 0),
		Vector2i(2, 0),
	]
	var actual_odd := mapGame.get_neightbours(pos_odd)
	assert_eq(actual_odd.size(), expected_odd.size())
	for p in expected_odd:
		assert_true(p in actual_odd)
	for p in actual_odd:
		assert_true(p in expected_odd)

	# Dijkstra/movimiento: invariantes simples (sin tamaños mágicos)
	var available := mapGame.get_accesible_moves(pos_even)
	assert_false(pos_even in available)
	var seen := {}
	for p in available:
		assert_true(p.x >= 0 and p.x < map.tamX)
		assert_true(p.y >= 0 and p.y < map.tamY)
		assert_false(seen.has(p))
		seen[p] = true
