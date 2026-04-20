extends GutTest


func test_name() -> void:
	var gameResources := GameResources.new()
	
	for script in gameResources.game_resources:
		var script_name := gameResources.get_folder_name(script)
		gut.logger.log(script_name)
		if script == MetadataRes:
			assert_null(gameResources.get(script_name))
		else:
			assert_not_null(gameResources.get(script_name))
