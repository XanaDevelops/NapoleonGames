extends GutTest


func test_name() -> void:
	var gameResources := GameResources.new()
	
	for script in gameResources.pack_order:
		var script_name := gameResources.get_folder_name(script)
		gut.logger.log(script_name)
		if script == MetadataRes:
			assert_null(gameResources.get(script_name))
		else:
			assert_not_null(gameResources.get(script_name))

func test_pack() -> void:
	var gameResources := GameResources.new()
	
	gameResources.pack()
	gameResources.save_to()
	assert_true(true)
	
func test_unpack() -> void:
	var gameResources := GameResources.load_from()
	gameResources.unpack()
	
	var testRes : AttackType = ResourceLoader.load("res://resources/attack_types/0001.tres")
	assert_eq(testRes.name, &"physic")
