extends Node

const PORT := 42069
const SERVER_PATH = &"localhost"
var peer := ENetMultiplayerPeer.new()

func create_server() -> bool:
	#var upnp := UPNP.new()
	#var err := upnp.discover()
	#if err != UPNP.UPNP_RESULT_SUCCESS:
		#push_error(error_string(err))
		#return false
	#err = upnp.add_port_mapping(PORT)
	#if err != UPNP.UPNP_RESULT_SUCCESS:
		#push_error(error_string(err))
		#return false
	
	var err := peer.create_server(PORT)
	if err != OK:
		push_error(error_string(err))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_client_join)
	
	return true
	
func _on_client_join(pid: int) -> void:
	prints("Cliente",pid)
	
func join_server() -> bool:
	var err := peer.create_client(SERVER_PATH, PORT)
	if err != OK:
		push_error(error_string(err))
		return false
	multiplayer.multiplayer_peer = peer
	
	return true
