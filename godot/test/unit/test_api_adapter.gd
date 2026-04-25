extends GutTest


func test_get_res() -> void:
	ApiAdapter.get_game_resource(1, UserRes)
	
	pass_test("ok?")

func test_to_json_dict() -> void:
	var res_test : HabilityRes = GameManager.get_game_resources().habilities[0]
	var res_test2 : CardRes = GameManager.get_game_resources().cards[0]
	var res_test3 : MapRes = GameManager.get_game_resources().maps[0]
	var res_test4 : UserRes = GameManager.get_game_resources().users[0]
	#ApiAdapter.send_game_resource(res_test)
	
	var scr : Script = HabilityRes
	
	print(scr.get_base_script() == GameResource)

	var text_hab := JSON.stringify(res_test.to_json_dict(), "\t")
	var text_card := JSON.stringify(res_test2.to_json_dict(), "\t")
	var text_map := JSON.stringify(res_test3.to_json_dict(), "\t")
	var text_user := JSON.stringify(res_test4.to_json_dict(), "\t")
	#print(text_hab)
	print(text_card)
	#print(text_map)
	#print(text_user)
	print("-------------------")
	var dict_hab : Dictionary = JSON.parse_string(text_hab)
	var dict_card : Dictionary = JSON.parse_string(text_card)
	var dict_map : Dictionary= JSON.parse_string(text_map)
	var dict_user : Dictionary = JSON.parse_string(text_user)
	#print(dict_hab)
	print(dict_card)
	#print(dict_map)
	#print(dict_user)
	print("------------------")
	var hab_res : HabilityRes = GameResource.parse_json(text_hab)
	var card_res : CardRes = GameResource.parse_json(text_card)
	var user_res : UserRes = GameResource.parse_json(text_user)
	#print(hab_res)
	#print(user_res)
	
	assert_eq(hab_res.uid, res_test.uid)
	assert_eq(hab_res.name, res_test.name)
	
	assert_eq(card_res.name, res_test2.name)
	assert_eq(card_res.img, res_test2.img)
	
	
	pass_test("mirar prints")
	
