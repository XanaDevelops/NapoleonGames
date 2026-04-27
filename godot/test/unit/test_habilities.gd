extends GutTest


@onready var card_melee : CardRes = preload("res://test/test_res/card_melee.tres")
@onready var card_ranged : CardRes = preload("res://test/test_res/card_ranged.tres")
@onready var map_test : MapRes = preload("res://test/test_res/map_test.tres")
@onready var user_ally : UserRes = preload("res://test/test_res/user_ally.tres")
@onready var user_enemy : UserRes = preload("res://test/test_res/user_enemy.tres")

@onready var tiles : Dictionary[int, TileTypeRes] = {
	0: preload("res://test/test_res/tile_type_pasto.tres"),
	1: preload("res://test/test_res/tile_type_montaña.tres")
}

var map_game : MapGame
var ally_units : Array[UnitGame] = []
var enemy_units: Array[UnitGame] = []


func test_ranges() -> void:
	var ally := ally_units[0]
	var enemy := enemy_units[0]
	
	var hab_esp := ally.get_all_habilities()[0]
	
	var pos := map_game.get_units_range(ally.get_current_position(), hab_esp.radius, hab_esp.objective)

	assert_eq(pos[0], enemy.get_current_position())
	
func test_attack_1() -> void:
	pass


func _before_all():
	# Crea y guarda el mapa de prueba
	
	var map_ids := [[0,0,0,0,0],
					[0,1,0,1,0],
					[0,1,0,1,0],
					[0,0,0,0,0]]
					
	self.map_test = MapRes.new()
	
	map_test.name = &"test_map_01"
	map_test.tamX = 5
	map_test.tamY = 4
	map_test.uid = 1
	
	var _uid := 1
	for row in map_ids:
		var aux : Array[TileRes]= []
		for t in row:
			var tile := TileRes.new()
			tile.height = 1
			tile.type = tiles.get(t)
			tile.uid = _uid
			_uid += 1 
			aux.append(tile)
		map_test.mapData.append(aux)
		
	map_test.mapData[0][4].height = 100000
	map_test.mapData[3][4].height = 100000
	
	ResourceSaver.save(map_test, "res://test/test_res/map_test.tres")

func before_each():
	map_game = MapGame.new(map_test)
	
	ally_units.clear()
	enemy_units.clear()
	
	# Crear unidades
	var unit: UnitGame
	
	unit = UnitGame.new(card_melee, user_ally)
	map_game.get_tile_at(Vector2i(0,0)).set_unit(unit)
	ally_units.append(unit)
	
	
	
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.get_tile_at(Vector2i(1,0)).set_unit(unit)
	enemy_units.append(unit)
	seed(666)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
