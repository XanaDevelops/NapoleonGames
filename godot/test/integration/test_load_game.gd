extends GutTest

var user0 : UserRes
var user1 : UserRes


func before_each():
	user0 = GameManager.get_game_resources().users[0]
	user1 = GameManager.get_game_resources().users[1]
	UserManager.meter_nuevo_usuario(user0)
	UserManager.meter_nuevo_usuario(user1)
	
	UserManager.establecer_usuario_actual(user0.email)
	
	UiManager.cambiar_a_escena("inicio")
	
	gut.pause_before_teardown()

func test_load_game() -> void:

	pass_test("ver UI")

func test_load_game_auto() -> void:
	GameManager.start_game(user0, user1,
			GameManager.get_game_resources().maps[0],
			user0.obtener_ejercito_activo(), user1.obtener_ejercito_activo())

	pass_test("ver UI")
