extends GutTest


func test_pack_unpack() -> void:
	var gameress := GameResources.new()
	
	## hacer que GameManager use este gameress
	GameManager._gameRes = gameress
	
	gameress.pack()
	gameress.save_to()
	gameress.unpack()
	
	pass_test("check")
	


func test_print_folder_names() -> void:
	for res in GameResources.game_resources:
		print(res.get_global_name(), " ", GameResources.get_folder_name(res))
	
	pass_test("check names!")


	
	
	
	
