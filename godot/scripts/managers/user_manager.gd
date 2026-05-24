extends Node


signal usuario_cambiado(email_activo,foto_de_perfil)
signal usuarios_actualizados


@export var mapas_de_prueba: Array[MapRes] = []

var usuarios: Dictionary = {}
var usuario_actual: UserRes

const AUTH_USERS_PATH := "user://usuarios_auth.json"

func _ready() -> void:
	cargar_usuarios_de_prueba()
	cargar_usuarios_autenticados()
	
	if not usuarios.is_empty():
		var primer_email = usuarios.keys()[0]
		establecer_usuario_actual(primer_email)
		
	usuarios_actualizados.emit()

func cargar_usuarios_de_prueba() -> void:
	var gr := GameResources.load_from() 
	
	
	if gr != null and not gr.users.is_empty(): 
		
		for usuario in gr.users: 
			
			if usuario != null:
				meter_nuevo_usuario(usuario) 
		
		


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
		usuario_cambiado.emit(usuario_actual.email,usuario_actual.img)
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

	guardar_usuarios_autenticados()

func guardar_ejercito(ejercito_a_guardar: ArmyRes, nombre_anterior: String) -> ArmyRes:
	if usuario_actual == null:
		return null

	var ejercitos = usuario_actual.userArmys
	var ejercito_guardado: ArmyRes = ejercito_a_guardar.clonar()
	var encontrado = false

	for i in range(ejercitos.size()):
		if ejercitos[i].nom == nombre_anterior:
			ejercitos[i] = ejercito_guardado
			encontrado = true
			break

	if not encontrado:
		ejercitos.append(ejercito_guardado)

	print("Ejército guardado localmente: " + str(ejercito_guardado.nom))
	print("Total ejércitos usuario actual: " + str(usuario_actual.userArmys.size()))

	guardar_usuarios_autenticados()
	usuarios_actualizados.emit()

	return ejercito_guardado

func eliminar_ejercito(nombre_ejercito: String) -> void:
	if usuario_actual == null:
		return

	var ejercitos = usuario_actual.userArmys

	for i in range(ejercitos.size() - 1, -1, -1):
		if ejercitos[i].nom == nombre_ejercito:
			ejercitos.remove_at(i)
			break

	guardar_usuarios_autenticados()
	usuarios_actualizados.emit()

func crear_user_res_desde_auth_response(auth_response: Dictionary) -> UserRes:
	if not auth_response.has("user"):
		push_error("Auth response sin user")
		return null

	var user_data: Dictionary = auth_response["user"]

	var user := UserRes.new()
	user.uid = int(user_data.get("id", 0))
	user.name = str(user_data.get("displayName", user_data.get("username", "")))
	user.username = StringName(str(user_data.get("username", "")))
	user.email = str(user_data.get("email", ""))
	user.token = str(auth_response.get("token", ""))

	aplicar_cartas_demo(user)

	return user


func registrar_usuario_autenticado(auth_response: Dictionary) -> void:
	var user := crear_user_res_desde_auth_response(auth_response)

	if user == null:
		return

	if user.email == "":
		push_error("Usuario autenticado sin email")
		return

	if usuarios.has(user.email):
		var usuario_existente: UserRes = usuarios[user.email]
		user.userArmys = usuario_existente.userArmys
		user.availableCards = usuario_existente.availableCards
		user.availableMaps = usuario_existente.availableMaps
		user.img = usuario_existente.img

	usuarios[user.email] = user
	usuario_actual = user

	print("Usuario autenticado activo: " + user.name)
	print("Ejércitos del usuario activo: " + str(user.userArmys.size()))

	usuarios_actualizados.emit()
	usuario_cambiado.emit(user.email, user.img)
	guardar_usuarios_autenticados()

func guardar_usuarios_autenticados() -> void:
	var datos := []

	for email in usuarios:
		var usuario: UserRes = usuarios[email]

		if usuario.token == "":
			continue

		var armies := []

		for army in usuario.userArmys:
			var cards := []

			for group in army.agrupations:
				cards.append({
					"cardId": group.cardType.uid,
					"quantity": group.n
				})

			armies.append({
				"backendId": army.backend_id,
				"name": str(army.nom),
				"isActive": army.isActive,
				"cards": cards
			})

		datos.append({
			"id": usuario.uid,
			"name": usuario.name,
			"username": str(usuario.username),
			"email": usuario.email,
			"token": usuario.token,
			"armies": armies
		})

	print("JSON GUARDADO EN: ", ProjectSettings.globalize_path(AUTH_USERS_PATH))
	print("JSON CONTENT: ", JSON.stringify(datos))

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
		usuario.uid = int(item.get("id", 0))
		usuario.name = item.get("name", "")
		usuario.username = StringName(item.get("username", ""))
		usuario.email = item.get("email", "")
		usuario.token = item.get("token", "")

		aplicar_cartas_demo(usuario)

		var armies_data = item.get("armies", [])

		if typeof(armies_data) == TYPE_ARRAY:
			for army_data in armies_data:
				var army := ArmyRes.new()
				army.backend_id = int(army_data.get("backendId", 0))
				army.nom = StringName(army_data.get("name", ""))
				army.isActive = bool(army_data.get("isActive", false))

				var cards_data = army_data.get("cards", [])

				if typeof(cards_data) == TYPE_ARRAY:
					for card_data in cards_data:
						var card_id := int(card_data.get("cardId", 0))
						var quantity := int(card_data.get("quantity", 0))

						var card_res := _buscar_carta_por_uid(card_id)

						if card_res != null and quantity > 0:
							var group := CardArmyGroup.new()
							group.cardType = card_res
							group.n = quantity
							army.agrupations.append(group)

				usuario.userArmys.append(army)
				print("Army cargado desde JSON: " + str(army.nom))
				print("Cartas del army: " + str(army.agrupations.size()))
				
		print("Usuario auth cargado: " + usuario.email)
		print("Ejércitos cargados para usuario: " + str(usuario.userArmys.size()))
		if usuarios.has(usuario.email):
			var usuario_local_existente: UserRes = usuarios[usuario.email]
			usuario.img = usuario_local_existente.img
		usuarios[usuario.email] = usuario
		
func aplicar_cartas_demo(usuario: UserRes) -> void:
	
	var gr := GameResources.load_from()

	if gr == null:
		push_warning("No se pudo cargar GameResources para copiar cartas demo")
		return

	for demo_user in gr.users:
		if demo_user != null and not demo_user.availableCards.is_empty():
			usuario.availableCards = demo_user.availableCards.duplicate(true)
			usuario.availableMaps = demo_user.availableMaps.duplicate(true)
			print("Cartas demo copiadas a: " + usuario.name)
			print("Cantidad cartas: " + str(usuario.availableCards.size()))
			return

	push_warning("No hay ningún usuario demo con cartas disponibles")

func _buscar_carta_por_uid(card_id: int) -> CardRes:
	var gr := GameResources.load_from()

	if gr == null:
		return null

	for card in gr.cards:
		if card != null and card.uid == card_id:
			return card

	push_warning("No se encontró CardRes con uid: " + str(card_id))
	return null
