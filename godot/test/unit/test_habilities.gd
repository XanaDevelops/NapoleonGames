extends GutTest


@onready var card_melee : CardRes = preload("res://test/test_res/card_melee.tres")
@onready var card_ranged : CardRes = preload("res://test/test_res/card_ranged.tres")
@onready var map_test : MapRes = preload("res://test/test_res/map_test.tres")
@onready var user_ally : UserRes = preload("res://test/test_res/user_ally.tres")
@onready var user_enemy : UserRes = preload("res://test/test_res/user_enemy.tres")



var map_game : MapGame
var ally_units : Array[UnitGame] = []
var enemy_units: Array[UnitGame] = []


func test_ranges() -> void:
	pass

func test_attack_1() -> void:
	pass


func before_each():
	map_game = MapGame.new(map_test)
	
	var unit: UnitGame
	
	unit = UnitGame.new(card_melee, user_ally)
	map_game.get_tile_at(Vector2i(0,0)).set_unit(unit)
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.get_tile_at(Vector2i(1,0)).set_unit(unit)
	
	seed(666)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
