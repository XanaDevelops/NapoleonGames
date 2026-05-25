extends Node

const DEFAULT_ONLINE_IP := "127.0.0.1"
const DEFAULT_ONLINE_PORT := 42069
const DEFAULT_API_IP := "127.0.0.1"
const DEFAULT_API_PORT := 8080

const _SECTION_ONLINE := "online"
const _SECTION_API := "api"

var _loaded := false
var _config := ConfigFile.new()
var _config_path := ""

func get_online_ip() -> String:
	_ensure_loaded()
	var ip := str(_config.get_value(_SECTION_ONLINE, "ip", DEFAULT_ONLINE_IP)).strip_edges()
	if _is_valid_ipv4(ip):
		return ip
	return DEFAULT_ONLINE_IP

func get_online_port() -> int:
	_ensure_loaded()
	var port := int(_config.get_value(_SECTION_ONLINE, "port", DEFAULT_ONLINE_PORT))
	if _is_valid_port(port):
		return port
	return DEFAULT_ONLINE_PORT

func get_api_ip() -> String:
	_ensure_loaded()
	var ip := str(_config.get_value(_SECTION_API, "ip", DEFAULT_API_IP)).strip_edges()
	if _is_valid_ipv4(ip):
		return ip
	return DEFAULT_API_IP

func get_api_port() -> int:
	_ensure_loaded()
	var port := int(_config.get_value(_SECTION_API, "port", DEFAULT_API_PORT))
	if _is_valid_port(port):
		return port
	return DEFAULT_API_PORT

func get_api_base_url() -> String:
	return "http://%s:%d" % [get_api_ip(), get_api_port()]

func _ensure_loaded() -> void:
	if _loaded:
		return

	_loaded = true
	_config_path = _get_config_path()

	var load_error := _config.load(_config_path)
	if load_error != OK:
		_set_defaults()
		_save_config()
		return

	if _ensure_defaults_in_file():
		_save_config()

func _get_config_path() -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://").path_join("server.ini")

	return OS.get_executable_path().get_base_dir().path_join("server.ini")

func _set_defaults() -> void:
	_config.set_value(_SECTION_ONLINE, "ip", DEFAULT_ONLINE_IP)
	_config.set_value(_SECTION_ONLINE, "port", DEFAULT_ONLINE_PORT)
	_config.set_value(_SECTION_API, "ip", DEFAULT_API_IP)
	_config.set_value(_SECTION_API, "port", DEFAULT_API_PORT)

func _ensure_defaults_in_file() -> bool:
	var changed := false

	if not _config.has_section_key(_SECTION_ONLINE, "ip"):
		_config.set_value(_SECTION_ONLINE, "ip", DEFAULT_ONLINE_IP)
		changed = true

	if not _config.has_section_key(_SECTION_ONLINE, "port"):
		_config.set_value(_SECTION_ONLINE, "port", DEFAULT_ONLINE_PORT)
		changed = true

	if not _config.has_section_key(_SECTION_API, "ip"):
		_config.set_value(_SECTION_API, "ip", DEFAULT_API_IP)
		changed = true

	if not _config.has_section_key(_SECTION_API, "port"):
		_config.set_value(_SECTION_API, "port", DEFAULT_API_PORT)
		changed = true

	return changed

func _save_config() -> void:
	var save_error := _config.save(_config_path)
	if save_error != OK:
		push_error("No se pudo guardar server.ini en: %s" % _config_path)

func _is_valid_port(port: int) -> bool:
	return port > 0 and port <= 65535

func _is_valid_ipv4(ip: String) -> bool:
	var parts := ip.split(".")
	if parts.size() != 4:
		return false

	for part in parts:
		if part.is_empty():
			return false
		if not part.is_valid_int():
			return false

		var value := int(part)
		if value < 0 or value > 255:
			return false

	return true
