extends GutTest

func before_each() -> void:
	UserManager.usuarios.clear()
	UserManager.usuario_actual = null

func test_setup_y_arranque_juego() -> void:
	var generador = TestUserGenerator.new()
	
	var j1 = generador.generar_usuario_completo()
	j1.name = "Jugador 1"
	j1.email = "p1"
	
	var j2 = generador.generar_usuario_completo()
	j2.name = "Jugador 2"
	j2.email = "p2"
	
	UserManager.meter_nuevo_usuario(j1)
	UserManager.meter_nuevo_usuario(j2)
	
	UserManager.establecer_usuario_actual("p1")
	
	assert_eq(UserManager.usuarios.size(), 2)
	assert_not_null(UserManager.usuario_actual)
	assert_eq(UserManager.usuario_actual.name, "Jugador 1")
	
	var escena_inicio = load("res://scenes/inicio.tscn")
	var instancia = escena_inicio.instantiate()
	
	add_child_autoqfree(instancia)
	
	gut.pause_before_teardown()
