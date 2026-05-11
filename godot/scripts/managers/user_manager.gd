extends Node

signal usuario_cambiado(email_activo)

@export var mapas_de_prueba: Array[MapRes] = []

var usuarios: Dictionary = {}
var usuario_actual: UserRes

func _ready() -> void:
	
	cargar_usuarios_de_prueba()

func cargar_usuarios_de_prueba() -> void:
	var gr := GameResources.load_from() 
	
	
	if gr != null and not gr.users.is_empty(): 
		
		for usuario in gr.users: 
			
			if usuario != null:
				meter_nuevo_usuario(usuario) 
		
		establecer_usuario_actual(gr.users[0].email)
		print(str(gr.users.size()) + " usuarios de prueba cargados con éxito.") 
	else:
		push_warning("No se encontraron usuarios de prueba en GameResources.")


func meter_nuevo_usuario(nuevo_usuario: UserRes) -> bool:
	if nuevo_usuario == null or nuevo_usuario.email == "":
		push_error("Error: Intento de registro de usuario nulo o sin email válido.")
		return false
		
	if usuarios.has(nuevo_usuario.email):
		push_warning("Registro denegado: El email proporcionado ya está en uso.")
		return false
		
	usuarios[nuevo_usuario.email] = nuevo_usuario
	return true

func establecer_usuario_actual(email_usuario: String) -> void:
	if usuarios.has(email_usuario):
		usuario_actual = usuarios[email_usuario]
		print("Usuario activo cambiado a: " + usuario_actual.name)
		usuario_cambiado.emit(usuario_actual.email)
	else:
		push_error("Error: Usuario no encontrado en el registro.")

func es_usuario_local(email_a_comprobar: String = "") -> bool:
	var email = email_a_comprobar
	if email == "" and usuario_actual != null:
		email = usuario_actual.email
		
	return not "@" in email

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
