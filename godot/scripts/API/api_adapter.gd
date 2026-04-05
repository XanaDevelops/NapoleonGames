class_name APIAdapter
extends Node

var _SERVER : StringName

const _HEADER : PackedStringArray = []

func _ready() -> void:
	## TODO, supongo que esto habrá que cambiarlo?...
	_SERVER = &"127.0.0.1"
	
	if _SERVER == &"127.0.0.1":
		push_warning("Se está usando localhost (127.0.0.1) como _SERVER")
	
func make_request(endpoint: StringName, request: Dictionary[StringName, Variant],method := HTTPClient.Method.METHOD_GET , server := _SERVER):
	_make_request(endpoint, JSON.stringify(request), method, server)
	
func _make_request(endpoint: StringName, request: String, method, server):
	var http := HTTPRequest.new()
	add_child(http)
	
	http.use_threads = true
	http.request_completed.connect(_parse_response)
	
	# realiza la petición
	var error := http.request(server+endpoint, _HEADER, method, request)
	
	if error != OK:
		push_error("ERROR in HTTP Request", error)
		
	
func _parse_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> JSON:
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	
	var response : Variant= json.data
	
	return json
	

	
