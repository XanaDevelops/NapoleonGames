extends GutTest

func test_cargar_datos_de_prueba() -> void:
	var usuario_prueba = UserRes.new()
	usuario_prueba.name = "Jugador Local"
	usuario_prueba.username = "test_user"
	
	var carta_esqueleto = CardRes.new()
	carta_esqueleto.name = "Guerrero Esqueleto" 
	carta_esqueleto.weight = 2                  
	carta_esqueleto.img = preload("res://assets/sprites/imagenes_de_cartas/esqueleto.jpg") 
	
	var carta_elfo = CardRes.new()
	carta_elfo.name = "Arquero Elfo"
	carta_elfo.weight = 1
	carta_elfo.img = preload("res://assets/sprites/imagenes_de_cartas/elfo.jpg")
	
	usuario_prueba.availableCards[carta_esqueleto] = 10
	usuario_prueba.availableCards[carta_elfo] = 10
	
	var ejercito_inicial = ArmyRes.new()
	ejercito_inicial.nom = "Horda Inicial"
	ejercito_inicial.isActive = false
	usuario_prueba.userArmys.append(ejercito_inicial)
	
	var ejercito_final = ArmyRes.new()
	ejercito_final.nom = "Horda final"
	ejercito_final.isActive = true
	usuario_prueba.userArmys.append(ejercito_final)
	
	UserManager.establecer_usuario_actual(usuario_prueba)
	
	var usuario_guardado = UserManager.usuario_actual
	
	assert_not_null(usuario_guardado)
	assert_eq(usuario_guardado.name, "Jugador Local")
	assert_eq(usuario_guardado.availableCards.size(), 2)
	assert_eq(usuario_guardado.userArmys.size(), 2)
