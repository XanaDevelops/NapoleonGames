class_name TestRealResources
extends GutTest

const MAP_SCENE_PATH: String = "res://scenes/ingame/game_scene.tscn"

func test_sandbox_interactivo_movimiento() -> void:
	var gr = GameResources.load_from()
	var user_a = gr.users[0]
	var user_b = gr.users[1]
	
	GameManager._gameMap = MapGame.new(gr.maps[0])
	
	var map_instance = load(MAP_SCENE_PATH).instantiate()
	add_child_autoqfree(map_instance)
	
	await wait_frames(2)
	var ingame_map = map_instance.get_node("IngameMap")
	autoqfree(ingame_map._hab_manager)
	
	var turn_manager = map_instance
	var visualizer = _find_visualizer_node(map_instance)
	
	var user_a_game := UserGame.new(user_a)
	var user_b_game := UserGame.new(user_b)
	turn_manager.turn_order.clear()
	turn_manager.turn_order.append(user_a_game)
	turn_manager.turn_order.append(user_b_game)
	turn_manager.turn_number = 0 
	
	var ally_unit = UnitGame.new(gr.cards[0], user_a_game)
	ally_unit._owner = user_a_game
	var ally_pos = Vector2i(0, 0) 
	var tile_ally = visualizer.map.get_tile_at(ally_pos)
	tile_ally.set_unit(ally_unit)
	ally_unit._tile = tile_ally
	
	var enemy_unit = UnitGame.new(gr.cards[1], user_b_game)
	enemy_unit._owner = user_b_game
	var enemy_pos = Vector2i(0, 1) 
	var tile_enemy = visualizer.map.get_tile_at(enemy_pos)
	tile_enemy.set_unit(enemy_unit)
	enemy_unit._tile = tile_enemy
	
	#visualizer._setup_map(GameManager.get_map())


	gut.pause_before_teardown()
	
	pass_test("mirar ui")

func _find_visualizer_node(node: Node) -> mapVisualizer:
	if node is mapVisualizer: 
		return node
	for child in node.get_children():
		var found = _find_visualizer_node(child)
		if found: 
			return found
	return null
