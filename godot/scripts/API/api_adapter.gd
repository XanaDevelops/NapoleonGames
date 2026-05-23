class_name APIAdapter
extends Node

var _SERVER: StringName = &"http://127.0.0.1:8080"

const _HEADER: PackedStringArray = [
	"Content-Type: application/json",
	"Accept: application/json"
]

func _auth_header(token: String) -> PackedStringArray:
	var headers := PackedStringArray(_HEADER)
	headers.append("Authorization: Bearer " + token)
	return headers

func _make_army_request(
	endpoint: StringName,
	request: String,
	method: int,
	server: StringName,
	headers: PackedStringArray,
	army: ArmyRes
) -> void:
	var http := HTTPRequest.new()
	add_child(http)

	http.use_threads = true
	http.request_completed.connect(_parse_army_response.bind(http, army))

	var route := server + endpoint

	print("REQUEST: ", route)
	print("BODY: ", request)

	var error := http.request(route, headers, method, request)

	if error != OK:
		push_error("ERROR in HTTP Request: " + str(error))

func _parse_army_response(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray,
	http: HTTPRequest,
	army: ArmyRes
) -> void:
	var text := body.get_string_from_utf8()

	print("STATUS: ", response_code)
	print("RAW RESPONSE: ", text)

	var json := JSON.new()
	var parse_error := json.parse(text)

	if parse_error != OK:
		push_error("Invalid JSON army response")
		http.queue_free()
		return

	var response = json.data

	if response_code >= 200 and response_code < 300:
		if response is Dictionary and response.has("armyId"):
			army.backend_id = int(response["armyId"])
			UserManager.guardar_usuarios_autenticados()
			print("Army backend id actualizado: ", army.backend_id)

		UserManager.guardar_usuarios_autenticados()
	else:
		push_error("Error guardando army: " + str(response))

	http.queue_free()

func _ready() -> void:
	if _SERVER == &"http://127.0.0.1:8080":
		print("API conectada a backend local 8080")

func get_game_resource(uid: int, res: Script) -> void:
	if res not in GameResources.game_resources:
		push_error("Se quiere obtener del server algo que no es un GameResource")
		return

	make_request(
		"/" + _get_format({"id": uid}),
		{},
		HTTPClient.Method.METHOD_GET
	)
	
func _get_format(body: Dictionary[String, Variant]) -> String:
	var res = "?"

	for key in body:
		res += key + "=" + str(body[key]) + "&"

	return res

func make_request(
		endpoint: StringName,
		request: Dictionary,
		method := HTTPClient.METHOD_GET,
		server := _SERVER
	) -> void:
	
	_make_request(endpoint, JSON.stringify(request), method, server)

func _make_request(
		endpoint: StringName,
		request: String,
		method: int,
		server: StringName
	) -> void:
	
	var http := HTTPRequest.new()
	add_child(http)

	http.use_threads = true
	http.request_completed.connect(_parse_response.bind(http))

	var route := server + endpoint

	print("REQUEST: ", route)
	print("BODY: ", request)

	var error := http.request(route, _HEADER, method, request)

	if error != OK:
		push_error("ERROR in HTTP Request: " + str(error))

func _parse_response(
		result: int,
		response_code: int,
		headers: PackedStringArray,
		body: PackedByteArray,
		http: HTTPRequest
	) -> void:
	
	var text := body.get_string_from_utf8()

	print("STATUS: ", response_code)
	print("RAW RESPONSE: ", text)

	var json := JSON.new()
	var parse_error := json.parse(text)

	if parse_error != OK:
		push_error("Invalid JSON response")
		http.queue_free()
		return

	var response = json.data
	
	if response is Dictionary and response.has("armyId"):
		print("Army guardado con id: ", response["armyId"])

	print("JSON RESPONSE: ", response)
	
	if response_code == 200 and typeof(response) == TYPE_DICTIONARY and response.has("token") and response.has("user"):
		UserManager.registrar_usuario_autenticado(response)
		UiManager.cambiar_a_escena("inicio")

	http.queue_free()

func login(username: String, password: String) -> void:
	var body := {
		"username": username,
		"password": password
	}

	make_request("/api/auth/login", body, HTTPClient.METHOD_POST)

func signin(
		username: String,
		email: String,
		password: String,
		display_name: String,
		profile_img: String = ""
	) -> void:
	
	var body := {
		"username": username,
		"email": email,
		"password": password,
		"displayName": display_name,
		"profileImg": profile_img
	}

	make_request("/api/auth/signin", body, HTTPClient.METHOD_POST)
	
func save_army(user: UserRes, army: ArmyRes) -> void:
	var cards := []

	for group in army.agrupations:
		cards.append({
			"cardId": group.cardType.uid,
			"quantity": group.n
		})

	var body := {
		"armyId": army.backend_id if army.backend_id > 0 else null,
		"userId": user.uid,
		"name": str(army.nom),
		"isActive": army.isActive,
		"cards": cards
	}

	_make_army_request(
		"/api/army",
		JSON.stringify(body),
		HTTPClient.METHOD_POST,
		_SERVER,
		_auth_header(user.token),
		army
	)
