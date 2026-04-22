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
	var unit := UnitGame.new(gr.cards[0])
	mapGame.get_tile_at(Vector2i(2,2)).set_unit(unit)
	
	var neight := mapGame.get_neightbours(Vector2i(2,2))
	print(neight)
	
	var test_neight := [Vector2i(1,2), Vector2i(3,2), Vector2i(2,1), Vector2i(2,3),
						Vector2i(1,1), Vector2i(1,3)]
	for test in test_neight:
		assert_true(test in neight)
		
	var available := mapGame.get_accesible_moves(Vector2i(2,2))
	print(available)
	
	assert_eq(available.size(), 13)
