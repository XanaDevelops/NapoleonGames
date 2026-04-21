extends GutTest


func test_pack_unpack() -> void:
	var gameress :=  GameManager.get_game_resources()
	gameress.pack()
	gameress.save_to()
	##gameress.unpack()
	##gameress.save_to()
	
	pass_test("check")
	


func test_print_folder_names() -> void:
	for res in GameResources.game_resources:
		print(res.get_global_name(), " ", GameResources.get_folder_name(res))
	
	pass_test("check names!")

func notest_borrar() -> void:
	var folder := "res://resources/"
	var gres := GameManager.get_game_resources()
	var b := func borrar(ares: ArmyRes):
		for cares: CardArmyGroup in ares.agrupations:
			gres._unpack(cares, folder + GameResources.get_folder_name(CardArmyGroup) +"/")
		gres._unpack(ares, folder + GameResources.get_folder_name(ArmyRes) + "/")
		
	var user1 : UserRes = load("res://resources/users/0001.tres")
	var user2 : UserRes = load("res://resources/users/0002.tres")
	
	b.call(user1.userArmys[0])
	b.call(user2.userArmys[0])
	

	
	
	
	
