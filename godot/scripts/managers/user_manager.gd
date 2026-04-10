extends Node

@export var mapas_de_prueba: Array[MapRes] = []
var jugador_1: UserRes
var jugador_2: UserRes


var usuario_actual: UserRes

func _ready() -> void:
	
	jugador_1 = TestUserGenerator.new().generar_usuario_completo()
	jugador_1.name = "Jugador 1" 
	
	jugador_2 = TestUserGenerator.new().generar_usuario_completo()
	jugador_2.name = "Jugador 2"
	
	
	usuario_actual = jugador_1

func establecer_usuario_actual(us_actual: UserRes)->void:
	usuario_actual=us_actual

func set_jugador_activo(es_jugador_uno: bool) -> void:
	if es_jugador_uno:
		usuario_actual = jugador_1
	else:
		usuario_actual = jugador_2
	print("El menú ahora está editando a: " + usuario_actual.name)
	
func obtener_mapas() -> Array[MapRes]:
	if usuario_actual == null or usuario_actual.availableMaps.is_empty():
		return mapas_de_prueba
	return usuario_actual.availableMaps

func obtener_ejercitos() -> Array:
	if usuario_actual == null or usuario_actual.userArmys == null:
		return []
	return usuario_actual.userArmys

func existe_ejercito(nombre_a_comprobar: String) -> bool:
	var ejercitos = obtener_ejercitos()
	for ejercito in ejercitos:
		if ejercito.nom == nombre_a_comprobar: return true
	return false

func establecer_ejercito_activo(nombre_ejercito_a_activar: String) -> void:
	var ejercitos = obtener_ejercitos()
	for ejercito in ejercitos:
		ejercito.isActive = (ejercito.nom == nombre_ejercito_a_activar)

func guardar_ejercito(ejercito_a_guardar: ArmyRes, nombre_anterior: String) -> void:
	if usuario_actual == null: return
	var ejercitos = usuario_actual.userArmys
	var encontrado = false
	for i in range(ejercitos.size()):
		if ejercitos[i].nom == nombre_anterior:
			ejercitos[i] = ejercito_a_guardar.clonar()
			encontrado = true
			break
	if not encontrado:
		ejercitos.append(ejercito_a_guardar.clonar())

func eliminar_ejercito(nombre_ejercito: String) -> void:
	if usuario_actual == null: return
	var ejercitos = usuario_actual.userArmys
	for i in range(ejercitos.size() - 1, -1, -1):
		if ejercitos[i].nom == nombre_ejercito:
			ejercitos.remove_at(i)
			break
