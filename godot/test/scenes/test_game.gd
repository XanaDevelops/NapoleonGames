class_name TestFullGame
extends GutTest

const MAP_SCENE_PATH: String = "res://scenes/ingame/game_scene.tscn"

var user_a: UserRes
var user_b: UserRes
var game_scene: TurnManager

func before_each():
	var gr := GameResources.load_from()
	user_a = gr.users[0]
	user_b = gr.users[1]

func after_each():
	game_scene = null


# Test desde menú — no toca nada interno
func test_full_game_from_start() -> void:
	var gr := GameResources.load_from()
	UserManager.meter_nuevo_usuario(gr.users[0])
	UserManager.meter_nuevo_usuario(gr.users[1])
	UserManager.establecer_usuario_actual(gr.users[0].email)
	UiManager.cambiar_a_escena("inicio")
	gut.pause_before_teardown()
	pass_test("Partida desde inicio")

# Test directo — usa start_game como haría el menú
func test_full_game_session() -> void:
	var gr := GameResources.load_from()
	var user_a = gr.users[0]
	var user_b = gr.users[1]
	
	GameManager.start_game(
		user_a, user_b,
		gr.maps[1],
		user_a.obtener_ejercito_activo(),
		user_b.obtener_ejercito_activo()
	)
	
	await wait_until(func(): return GameManager.turn_manager != null, 5)
	
	assert_true(GameManager.turn_manager.is_deployment_phase)
	gut.pause_before_teardown()
	pass_test("Partida directa")
