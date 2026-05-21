extends Node

signal usuario_cambiado(email_activo)
signal usuarios_actualizados

@export var mapas_de_prueba: Array[MapRes] = []

var usuarios: Dictionary = {}
var usuario_actual: UserRes

const AUTH_USERS_PATH := "user://usuarios_auth.json"

func _ready() -> void:
	cargar_usuarios_de_prueba()
	cargar_usuarios_autenticados()
	usuarios_actualizados.emit()

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

func crear_user_res_desde_auth_response(auth_response: Dictionary) -> UserRes:
	if not auth_response.has("user"):
		push_error("Auth response sin user")
		return null

	var user_data: Dictionary = auth_response["user"]

	var user := UserRes.new()
	user.name = str(user_data.get("displayName", user_data.get("username", "")))
	user.username = StringName(str(user_data.get("username", "")))
	user.email = str(user_data.get("email", ""))
	user.token = str(auth_response.get("token", ""))

	return user


func registrar_usuario_autenticado(auth_response: Dictionary) -> void:
	var user := crear_user_res_desde_auth_response(auth_response)

	if user == null:
		return

	if user.email == "":
		push_error("Usuario autenticado sin email")
		return

	if usuarios.has(user.email):
		usuarios[user.email] = user
	else:
		usuarios[user.email] = user

	usuario_actual = user

	print("Usuario autenticado activo: " + user.name)

	usuarios_actualizados.emit()
	usuario_cambiado.emit(user.email)
	guardar_usuarios_autenticados()
	

func guardar_usuarios_autenticados() -> void:
	var datos := []

	for email in usuarios:
		var usuario: UserRes = usuarios[email]

		if usuario.token == "":
			continue

		datos.append({
			"name": usuario.name,
			"username": str(usuario.username),
			"email": usuario.email,
			"token": usuario.token
		})

	var file := FileAccess.open(AUTH_USERS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(datos))
	file.close()


func cargar_usuarios_autenticados() -> void:
	if not FileAccess.file_exists(AUTH_USERS_PATH):
		return

	var file := FileAccess.open(AUTH_USERS_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var datos = JSON.parse_string(content)

	if typeof(datos) != TYPE_ARRAY:
		return

	for item in datos:
		var usuario := UserRes.new()
		usuario.name = item.get("name", "")
		usuario.username = StringName(item.get("username", ""))
		usuario.email = item.get("email", "")
		usuario.token = item.get("token", "")

		usuarios[usuario.email] = usuario
