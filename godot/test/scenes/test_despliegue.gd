class_name TestSandboxDespliegue
extends GutTest

const MAP_SCENE_PATH: String = "res://scenes/ingame/game_scene.tscn"

func test_sandbox_interactivo_fase_despliegue() -> void:
	var gr := GameResources.load_from() 
	var user_a: UserRes = gr.users[0]
	var user_b: UserRes = gr.users[1]
	
	GameManager.start_game(user_a, user_b, gr.maps[2], user_a.userArmys[0], user_b.userArmys[0])
	
	#var game_scene := load(MAP_SCENE_PATH).instantiate() as TurnManager
	
	
	#game_scene.turn_order = [user_a, user_b]
	#game_scene.turn_number = 0 
	
	
	#game_scene.player_deployment_data[user_a] = _get_cloned_army(user_a)
	#game_scene.player_deployment_data[user_b] = _get_cloned_army(user_b)
	#add_child_autoqfree(game_scene)
	await wait_frames(2)
	
	
	gut.pause_before_teardown()
	pass_test("Sandbox de despliegue finalizado.")
