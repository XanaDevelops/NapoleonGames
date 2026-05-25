extends GutTest

func before_each():
	GameManager.game_res = GameResources.load_from("res://test/test_res/all_test_resources.tres")
	var gr := GameManager.get_game_resources()
	GameManager.start_game(
		gr.users[0],
		gr.users[1],
		gr.maps[0],
		gr.users[0].userArmys[0],
		gr.users[1].userArmys[0]
	)
	await get_tree().process_frame

func _test_create_turns():
	gut.pause_before_teardown()
	
	var turns:= GameManager.get_turn_manager().turns
	await GameManager.get_turn_manager().game_end
	
	await get_tree().process_frame
	
	for t in turns:
		ResourceSaver.save(t, "res://test/test_res/turns/turn_action_"+str(t.action_order)+".tres")

	
func test_replay():
	var turns : Array[TurnAction] = []
	
	for f in DirAccess.get_files_at("res://test/test_res/turns/"):
		turns.append(load("res://test/test_res/turns/"+f) as TurnAction)

	turns.sort_custom(func(a: TurnAction, b: TurnAction) -> bool:
		return a.action_order < b.action_order
	)
		
		
	var tm := GameManager.get_turn_manager()
	autoqfree(get_tree().current_scene)
	await get_tree().process_frame
	for t in turns:
		assert_true(await tm.replay_turn(t))
		#await wait_seconds(0.5)
		# Pause between turns until the GUT Continue button is pressed.
		gut.start_pause_before_teardown.emit()
		await wait_for_signal(gut.end_pause_before_teardown, 0.5, "waiting for GUT continue")
	
	pass_test("pass")
