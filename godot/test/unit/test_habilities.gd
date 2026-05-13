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
	
	# esperamos tener a la unidad a rango
	var pos := map_game.get_units_range(ally.get_current_position(), hab_esp.radius, hab_esp.objective)
	assert_eq(pos[0], enemy.get_current_position())
	
	# miramos que no esté a rango
	map_game.move_unit(Vector2i(1,0), Vector2i(4,0))
	assert_eq(map_game.get_units_range(ally.get_current_position(), hab_esp.radius, hab_esp.objective).size(), 0)
	map_game.move_unit(Vector2i(4,0), Vector2i(1,0))

	

func test_attack_1() -> void:
	var ally := ally_units[0]
	var enemy := enemy_units[0]
	
	var hab_esp := ally.get_all_habilities()[0]
	
	var ene_hp := enemy.hp
	assert_true(ally.use_hability(hab_esp, [enemy]))
	assert_lt(enemy.hp, ene_hp)
	
func test_attack_2() -> void:
	var ally := ally_units[1]
	
	#arco
	var hab_arc := ally.get_all_habilities()[0]
	
	var old_hps := enemy_units.map(func (x: UnitGame) -> int: return x.hp)
	
	# de paso comprobamos rangos
	var ranges := GameManager.get_map().get_units_range(ally.get_current_position(), hab_arc.radius, hab_arc.objective)
	assert_eq(ranges.size(), 3)
	
	# usar TurnManager para variar
	GameManager.get_turn_manager()._on_unit_hability_use(ally.get_current_position(), ranges, hab_arc)
	
	for i in range(3):
		assert_lt(enemy_units[i].hp, old_hps[i])
		
	assert_eq(enemy_units[3].hp, old_hps[3])
	
func test_passive() -> void:
	test_attack_1()
	var ally := ally_units[0]
	var enemy := enemy_units[0]
	
	var old_hp := enemy.hp
	# manualmente avanzar turno del enemigo
	GameManager.get_turn_manager().advance_turn()
	#enemy.advance_turn()
	assert_gt(enemy.hp, old_hp)
	
func test_passive2() -> void:
	var ally := ally_units[1] #ranged
	var enemy := enemy_units[0] #melee
	
	var old_hp := enemy.hp
	# manualmente avanzar turno del enemigo
	GameManager.get_turn_manager().advance_turn()
	GameManager.get_turn_manager().advance_turn()
	#enemy.advance_turn()
	assert_lt(enemy.hp, old_hp)
	
func test_alter_state() -> void:
	var ally := ally_units[1]
	
	#arco
	var hab_fire := ally.get_all_habilities()[1]
	
	var old_hps := enemy_units.map(func (x: UnitGame) -> int: return x.hp)
	
	# de paso comprobamos rangos
	var ranges := GameManager.get_map().get_units_range(ally.get_current_position(), hab_fire.radius, hab_fire.objective)
	assert_eq(ranges.size(), 3)
	
	# usar TurnManager para variar
	GameManager.get_turn_manager()._on_unit_hability_use(ally.get_current_position(), ranges, hab_fire)
	
	# Comprobar vida y que se haya aplicado la quemadura
	for i in range(3):
		assert_lt(enemy_units[i].hp, old_hps[i])
		assert_eq(enemy_units[i]._currentAlterStates.size(),1)
		
	assert_eq(enemy_units[3].hp, old_hps[3])
	
	# avanzar turno
	old_hps = enemy_units.map(func (x: UnitGame) -> int: return x.hp)
	
	GameManager.get_turn_manager().advance_turn()
	# Recuerda que tambien aplica la cura, la diferencia deberia ser de 1!
	for i in range(3):
		assert_lt(enemy_units[i].hp, old_hps[i])
		assert_eq(enemy_units[i]._currentAlterStates.size(),1)
		
	assert_eq(enemy_units[3].hp, old_hps[3])
	
func test_alter_state2():
	var tm := GameManager.get_turn_manager()
	
	var ally := ally_units[0]
	#kaboom
	var hab_kaboom := ally.get_all_habilities()[2]
	
	var old_hps := enemy_units.map(func (x: UnitGame) -> int: return x.hp)
	
	tm._on_unit_hability_use(ally.get_current_position(), [], hab_kaboom)
	tm.advance_turn()
	tm.advance_turn()
	
	for i in range(4):
		assert_lt(enemy_units[i].hp, old_hps[i], "Unidad: " + str(i))
	

func test_condition():
	pass
	
	
func before_all():
	# Crea y guarda el mapa de prueba
	var map_ids := [[0,0,0,0,0],
					[0,1,0,1,0],
					[0,1,0,1,0],
					[0,1,0,1,0],
					[0,0,0,0,0]]
					
	self.map_test = MapRes.new()
	
	map_test.name = &"test_map_01"
	map_test.tamX = 5
	map_test.tamY = 5
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
	
	if ResourceSaver.save(map_test, "res://test/test_res/map_test.tres") != OK:
		fail_test("error al guardar!")
	

func before_each():
	map_game = MapGame.new(map_test)
	
	ally_units.clear()
	enemy_units.clear()
	
	# Crear unidades
	var unit: UnitGame
	var tm : TurnManager = autofree(TurnManager.new())
	tm.turn_order = [user_ally, user_enemy]
	GameManager.register_turn_manager(tm)
	GameManager.set_map(map_game)
	GameManager._app_state = GameManager.APP_STATE.IN_GAME
	
	unit = UnitGame.new(card_melee, user_ally)
	map_game.place_unit(unit, Vector2i(0,0))
	#tm.tick_turn.connect(unit.advance_turn)
	ally_units.append(unit)
	
	unit = UnitGame.new(card_ranged, user_ally)
	map_game.place_unit(unit, Vector2i(0,1))
	#tm.tick_turn.connect(unit.advance_turn)

	ally_units.append(unit)
	
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.place_unit(unit, Vector2i(1,0))
	#tm.tick_turn.connect(unit.advance_turn)
	enemy_units.append(unit)
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.place_unit(unit, Vector2i(2,0))
	#tm.tick_turn.connect(unit.advance_turn)
	enemy_units.append(unit)
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.place_unit(unit, Vector2i(3,0))
	#tm.tick_turn.connect(unit.advance_turn)
	enemy_units.append(unit)
	unit = UnitGame.new(card_melee, user_enemy)
	map_game.place_unit(unit, Vector2i(4,4))
	#tm.tick_turn.connect(unit.advance_turn)
	enemy_units.append(unit)
	
	
	seed(666)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
