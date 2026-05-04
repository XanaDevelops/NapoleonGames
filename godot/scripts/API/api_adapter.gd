class_name APIAdapter
extends Node

var _SERVER : StringName = &"http://127.0.0.1:8000"

const _HEADER : PackedStringArray = []

func _ready() -> void:
	if _SERVER == &"http://127.0.0.1:8000":
		push_warning("Se está usando localhost (127.0.0.1) como _SERVER")
	
## Manda al server el recurso
## Si este tiene subrecursos, los enviará antes
func send_game_resource(res : GameResource)	-> void:
	var body := res.to_json_dict()
	
	

		
	
## Guarda en el GameResources de GameManager el recurso solicitado
## Si ya existe, lo actualiza
## Si no existe, lo guarda
## Si el GameResource solicitado tiene dependencias, las pedirá i actualizará
func get_game_resource(uid: int, res: Script) -> void:
	if res not in GameResources.game_resources:
		push_error("Se quiere obtener del server algo que no es un GameResource")
		return
	make_request("/" + _get_format({"id":uid}), {}, HTTPClient.Method.METHOD_GET)

func _get_format(body: Dictionary[String, Variant]) -> String:
	var res = "?"
	for key in body:
		res += key + "=" + str(body[key]) + "&"
	return res

## Envia un request en formato diccionario
## Por ejemplo
## {a : 123,
##  b : [1,2,3],
##  c : {x:1, y:"hola"}} 
func make_request(endpoint: StringName, request: Dictionary[StringName, Variant],
					method := HTTPClient.Method.METHOD_GET , server := _SERVER):
	_make_request(endpoint, JSON.stringify(request), method, server)
	
func _make_request(endpoint: StringName, request: String, method: HTTPClient.Method, server: StringName):
	var http := HTTPRequest.new()
	add_child(http)
	
	http.use_threads = true
	http.request_completed.connect(_parse_response)
	
	
	var _route := server+endpoint
	print(_route)
	# realiza la petición
	var error := http.request(server+endpoint, _HEADER, method, request)
	
	if error != OK:
		push_error("ERROR in HTTP Request", error)
		
	
func _parse_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> JSON:
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	
	var response : Variant= json.data
	
	print(response)
	return json
	

	
