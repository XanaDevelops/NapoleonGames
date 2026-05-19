extends Node

var peer_ids: Array[int]

## Juegos activos
var current_games: Dictionary[int, TurnManager] = {}

## Usuarios esperando
var waiting: Dictionary[int, OnlineMatchRequest] = {}

func _ready() -> void:
	Online.on_peer_connected.connect(on_peer_connected)
	Online.on_peer_disconnected.connect(on_peer_disconnected)
	Online.on_server_packet.connect(on_server_packet)


func on_peer_connected(peer_id: int) -> void:
	peer_ids.append(peer_id)

	IDAssignment.create(peer_id).send(Online.client_peers[peer_id])
	print("[Server] enviado IDAssignment ", peer_id)

func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

	# Create IDUnassignment to broadcast to all still connected peers


func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	match data[0]:
		NetPacket.PACKET_TYPE.PING:
			manage_ping(PingPacket.create_from_data(data))
		NetPacket.PACKET_TYPE.REQUEST_ONLINE:
			manage_game_request(peer_id, OnlineMatchRequest.create_from_data(data))
		NetPacket.PACKET_TYPE.TURN_ACTION:
			pass
		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ping(ping : PingPacket) -> void:
	ping.message = "From server: " + ping.message
	_broadcast(ping)
	
	
func manage_game_request(pid: int, request: OnlineMatchRequest) -> void:
	# Por ahora esto va bien
	var gr := GameManager.get_game_resources()
	if waiting.size() > 1:
		var other_pid : int = waiting.keys()[0]
		var other : OnlineMatchRequest = waiting[other_pid]
		waiting.erase(other_pid)
		var user_a : UserRes = gr.get_res_from_uid(request.user_uid, UserRes)
		var user_b : UserRes = gr.get_res_from_uid(other.user_uid, UserRes)
		var map : MapRes = gr.get_res_from_uid(request.desired_map_uid if randf() <= 0.5 else other.desired_map_uid, MapRes)
		var army_a : ArmyRes = gr.get_res_from_uid(request.army_uid, ArmyRes)
		var army_b : ArmyRes = gr.get_res_from_uid(other.army_uid, ArmyRes)
		
		var game_id := randi()
		# Seguramente habrá que hacerlo de otra forma, pero por ahora va bien
		GameManager.start_game(user_a, user_b, map, army_a, army_b, true)
		
		var tm := GameManager.get_turn_manager()
		
		var lobby := GameLobby.create(game_id, user_a.uid, user_b.uid, map.uid, army_a.uid, army_b.uid)
		lobby.send(Online.client_peers[pid])
		lobby.send(Online.client_peers[other_pid])
		
	else:
		waiting.set(pid, request)
	
func _broadcast(packet : NetPacket) -> void:
	Online.connection.broadcast(0, packet.encode(), packet.flag)
