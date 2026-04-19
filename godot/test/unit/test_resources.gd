extends GutTest


func test_test() -> void:
	pass


func test_print_folder_names() -> void:
	for res in GameResources.game_resources:
		print(res.get_global_name(), " ", GameResources.get_folder_name(res))
	
	pass_test("check names!")
