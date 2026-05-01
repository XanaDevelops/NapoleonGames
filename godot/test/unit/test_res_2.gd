extends GutTest


func test_name() -> void:
	var gameResources := GameResources.new()
	
	for script in gameResources.game_resources:
		var script_name := gameResources.get_folder_name(script)
		gut.logger.log(script_name)
		if script == MetadataRes or script == CardArmyGroup:
			assert_null(gameResources.get(script_name))
		else:
			assert_not_null(gameResources.get(script_name))

func test_pack() -> void:
	var gameResources := GameManager.get_game_resources()
	print("test")
	gameResources.pack()
	gameResources.save_to()
	assert_true(true)
	
func test_unpack() -> void:
	var gameResources := GameManager.get_game_resources()
	gameResources.unpack()
	gameResources.save_to()
	
	var testRes : AttackType = ResourceLoader.load("res://resources/attack_types/0001.tres")
	assert_eq(testRes.name, &"physic")
