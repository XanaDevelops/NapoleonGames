extends GutTest


const CARD_A_PATH = "res://test/test_res/card_melee.tres"
const CARD_B_PATH = "res://test/test_res/card_ranged.tres"

func _create_test_unit(card_path: String, owner: UserGame) -> UnitGame:
	var card = load(card_path) as CardRes
	assert_not_null(card, "No se pudo cargar: " + card_path)
	return UnitGame.new(card, owner)
func _assert_subscribed(tm: TurnManager, unit: UnitGame, expected: bool, msg: String) -> void:
	var connected = tm.tick_turn.is_connected(unit.advance_turn)
	assert_eq(connected, expected, msg)

func _set_unit_used(unit: UnitGame, hab: HabilityRes, cooldown: int) -> void:
	unit._habilities[hab] = cooldown
	unit.has_moved_this_turn = true
	unit.has_used_hability_this_turn = true

func _create_poison() -> AlterStateRes:
	var state = AlterStateRes.new()
	state.stat = StatData.new()
	state.stat.name = &"hp"
	state.stat.isPercent = false
	state.value = -5.0
	state.hitP = 1.0
	state.duration = 3
	state.objective = HabilityRes.SEL_SELF_FLAG
	return state
	
func _advance_and_wait(tm: TurnManager) -> void:
	tm.advance_turn()
	await wait_physics_frames(2)

func _setup_game_environment() -> Dictionary:
	var gr := GameResources.load_from("res://test/test_res/all_test_resources.tres")
	var test_map_game : TestMapGame = autofree(TestMapGame.new())
	var map := test_map_game.create_test_map()
	GameManager.game_config = GameConfig.new(
		gr.users[0],
		gr.users[1],
		map._mapRes,
		gr.users[0].obtener_ejercito_activo(),
		gr.users[1].obtener_ejercito_activo()
	)
	var user_a_game := UserGame.new(gr.users[0])
	var user_b_game := UserGame.new(gr.users[1])
	
	var prev_add_target = gut.add_children_to
	gut.add_children_to = get_tree().get_root()
	var instance := preload("res://scenes/ingame/game_scene.tscn").instantiate() as TurnManager
	instance.turn_order = [user_a_game, user_b_game]
	instance.turn_number = 0
	instance.set_map(map)
	add_child_autoqfree(instance)
	instance.set_app_state(GameManager.APP_STATE.IN_GAME)
	
	return {
		"tm": instance,
		"map": map,
		"user_a": user_a_game,
		"user_b": user_b_game,
		"prev_add_target": prev_add_target,
	}
func test_advance_turn_updates_units() -> void:
	var env := _setup_game_environment()
	var tm: TurnManager = env.tm
	var map: MapGame = env.map
	
	var unit_a = _create_test_unit(CARD_A_PATH, env.user_a)
	var unit_b = _create_test_unit(CARD_B_PATH, env.user_b)
	
	map.place_unit(unit_a, Vector2i(5, 5))
	map.place_unit(unit_b, Vector2i(10, 5))
	
	await wait_until(func(): return tm.is_inside_tree(), 5)
	await wait_physics_frames(2)
	var ingame_map = tm.get_node("IngameMap")
	autoqfree(ingame_map._hab_manager)
	

	_assert_subscribed(tm, unit_a, true, "Unit A debe estar suscrita")
	_assert_subscribed(tm, unit_b, true, "Unit B debe estar suscrita")
	
	var hab_a = unit_a._cardRes.habilities[0]
	_set_unit_used(unit_a, hab_a, 2)
	var hab_b = unit_b._cardRes.habilities[0]
	_set_unit_used(unit_b, hab_b, 3)
	
	#  turno de user_b —
	await _advance_and_wait(tm)
	
	assert_eq(unit_b._habilities[hab_b], 2, "Cooldown B debe bajar a 2")
	assert_false(unit_b.has_moved_this_turn, "B debe poder moverse")
	assert_false(unit_b.has_used_hability_this_turn, "B debe poder usar habilidad")
	assert_eq(unit_a._habilities[hab_a], 2, "Cooldown A no debe cambiar")
	# Ya no es así por cambio para QoL interfaz
	#assert_true(unit_a.has_moved_this_turn, "A no debe resetearse aún")
	
	# turno de user_a 
	await _advance_and_wait(tm)
	
	assert_eq(unit_a._habilities[hab_a], 1, "Cooldown A debe bajar a 1")
	assert_false(unit_a.has_moved_this_turn, "A debe poder moverse")
	
	#Alter states con SEL_SELF expiran 
	# poison en unit_a solo toca en turno de user_a
	var poison = _create_poison()
	unit_a._currentAlterStates[poison] = 1
	
	await _advance_and_wait(tm)  # turno user_b 
	await _advance_and_wait(tm)  # turno user_a 
	
	assert_false(unit_a._currentAlterStates.has(poison), "Veneno debe haber expirado")
	
	#  Alter states aplican daño cada turno
	var poison2 = _create_poison()
	unit_b._currentAlterStates[poison2] = 3
	var hp_before_poison = unit_b.hp
	
	await _advance_and_wait(tm)  # turno user_b — veneno aplica daño
	
	assert_lt(unit_b.hp, hp_before_poison, "Veneno debe dañar a Unit B")
	assert_eq(unit_b._currentAlterStates[poison2], 2, "Veneno debe tener 2 turnos restantes")
	
	#  Kill desuscribe
	#unit_b.kill()
	await wait_physics_frames(2)
	
	_assert_subscribed(tm, unit_b, false, "Unit B muerta no debe estar suscrita")
	
	#  Cooldown llega a 0 
	unit_a._habilities[hab_a] = 1
	await _advance_and_wait(tm)  # turno user_a
	
	assert_eq(unit_a._habilities[hab_a], 0, "Cooldown debe llegar a 0")
	
	gut.pause_before_teardown()
	pass_test("advance_turn and tick_turn work correctly")
	gut.add_children_to = env.prev_add_target
