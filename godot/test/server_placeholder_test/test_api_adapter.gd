extends GutTest


func test_get_res() -> void:
	ApiAdapter.get_game_resource(1, UserRes)
	
	pass_test("ok?")

func test_post_res() -> void:
	var res_test := GameManagerNode.get_game_resources().habilities[0]
	var res_test2 := GameManagerNode.get_game_resources().cards[0]
	var res_test3 := GameManagerNode.get_game_resources().maps[0]
	#ApiAdapter.send_game_resource(res_test)
	
	var scr : Script = HabilityRes
	
	print(scr.get_base_script() == GameResource)
	var aux := res_test.to_json_dict()
	var text_hab := JSON.stringify(aux, "\t")
	var text_card := JSON.stringify(res_test2.to_json_dict(), "\t")
	var text_map := JSON.stringify(res_test3.to_json_dict(), "\t")
	print(text_hab)
	print(text_card)
	print(text_map)
	
	var dict_card : Dictionary = JSON.parse_string(text_card)
	var dict_map : Dictionary= JSON.parse_string(text_map)
	print(dict_card)
	print(dict_card["resistances"])
	for key : String in dict_card["resistances"]:
		print(JSON.parse_string(key))
	print(dict_map)
	
	pass_test("OK?")
	
