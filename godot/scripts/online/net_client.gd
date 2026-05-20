extends Node

signal handle_local_id_assignment(local_id: int)
signal server_turn_response(accepted: bool)

var id: int = -1

func _ready() -> void:
	Online.on_client_packet.connect(on_client_packet)


func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		NetPacket.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))
		NetPacket.PACKET_TYPE.PING:
			manage_ping(PingPacket.create_from_data(data))
		NetPacket.PACKET_TYPE.SET_GAME_LOBBY:
			enter_online_game(GameLobby.create_from_data(data))
			
		NetPacket.PACKET_TYPE.TURN_ACTION:
			GameManager.get_turn_manager().replay_turn(TurnAction.create_from_data(data))
		NetPacket.PACKET_TYPE.TURN_RESULT:
			manage_turn_result(TurnNetResult.create_from_data(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ids(id_assignment: IDAssignment) -> void:
	if id == -1: # When id == -1, the id sent by the server is for us
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id)

	prints("my id", id)
	
## TODO: preguntar por mapa, config, etc
## Pide iniciar una partida online
func request_online_game() -> void:
	var user := UserManager.usuario_actual
	
	## PLACEHOLDER
	var map := GameManager.get_game_resources().maps[2]
	var packet := OnlineMatchRequest.create(user.uid, user.obtener_ejercito_activo().uid, map.uid)
	packet.send(Online.server_peer)
	
	print("requested ", NetClient.id)
	
	
	
func enter_online_game(lobby: GameLobby) -> void:
	var gr := GameManager.get_game_resources()
	await get_tree().process_frame
	GameManager.start_game.call_deferred(
		gr.get_res_from_uid(lobby.user_a_uid, UserRes) as UserRes,
		gr.get_res_from_uid(lobby.user_b_uid, UserRes) as UserRes,
		gr.get_res_from_uid(lobby.map_res_uid, MapRes) as MapRes,
		gr.get_res_from_uid(lobby.army_a_uid, ArmyRes) as ArmyRes,
		gr.get_res_from_uid(lobby.army_b_uid, ArmyRes) as ArmyRes,
		true,
		lobby.game_pid
	)

func manage_turn_result(turn: TurnNetResult) -> void:
	server_turn_response.emit(turn.is_valid)

func manage_ping(ping : PingPacket) -> void:
	print("["+str(id)+"] "+"PING: ", ping.message)
