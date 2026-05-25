class_name TestSandboxDespliegue
extends GutTest

func test_sandbox_integracion_despliegue() -> void:
	var gr := GameResources.load_from() 
	var user_a = gr.users[0]
	var user_b = gr.users[1]
	
	# Esto inicializa todo el sistema como lo haría el juego real
	GameManager.start_game(
		user_a, 
		user_b, 
		gr.maps[2], 
		user_a.obtener_ejercito_activo(), 
		user_b.obtener_ejercito_activo()
	)
	
	# Esperamos a que la escena se instancie y el TurnManager se registre
	await wait_until(func(): return GameManager.turn_manager != null, 5)
	await get_tree().process_frame
	var game_scene = GameManager.turn_manager
	autoqfree(get_tree().current_scene)
	var ingame_map = get_tree().current_scene.get_node("IngameMap")
	autoqfree(ingame_map._hab_manager)
	
	assert_not_null(game_scene)
	assert_true(game_scene.is_deployment_phase)
	
	gut.pause_before_teardown()
