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
	print(JSON.stringify(aux, "\t"))
	print(JSON.stringify(res_test2.to_json_dict(), "\t"))
	print(JSON.stringify(res_test3.to_json_dict(), "\t"))
	pass_test("OK?")
	
