extends Node

signal handle_local_id_assignment(local_id: int)
signal server_turn_response(accepted: bool)
signal server_randf_response(val: float)
signal randf_available()

var id: int = -1

var mutex:= Mutex.new()
var _randf_in_flight: bool = false

## Variable para saber si el cliente esta actualmente conectado
## FIXME: manejar casos de desconexión
var connected := false

func _ready() -> void:
	Online.on_client_packet.connect(on_client_packet)
	Online.on_connected_to_server.connect(_on_connected_to_server)
	Online.on_disconnected_from_server.connect(_on_disconnected_from_server)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_close_active_connection()


func _close_active_connection() -> void:
	if Online == null:
		return

	if Online.is_server:
		return

	if Online.connection == null:
		connected = false
		return

	if Online.server_peer != null:
		Online.disconnect_client()

	connected = false


func _on_connected_to_server() -> void:
	connected = true


func _on_disconnected_from_server() -> void:
	connected = false


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
		NetPacket.PACKET_TYPE.FORCE_WIN_NOTIF:
			manage_force_win_notif(NetForceWinNotif.create_from_data(data))
		NetPacket.PACKET_TYPE.RANDF:
			manage_randf(NetRandF.create_from_data(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ids(id_assignment: IDAssignment) -> void:
	if id == -1: # When id == -1, the id sent by the server is for us
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id)
	#tenemos id, estamos online
	self.connected = true
	prints("my id", id)
	
## TODO: preguntar por mapa, config, etc
## Pide iniciar una partida online
func request_online_game(user: UserRes, army: ArmyRes, map : MapRes, friend: UserRes = null) -> void:
	
	## PLACEHOLDER
	if map == null:
		map = GameManager.get_game_resources().maps[2]
	var packet := OnlineMatchRequest.create(user.uid, army.uid, map.uid, friend.uid if friend else -1)
	packet.send(Online.server_peer)
	
	print("requested ", NetClient.id, "random" if not friend else "amigo")
	
	
func request_randf_server() -> float:
	if GameManager.is_server:
		return NetServer.manage_randf(-1, NetRandF.create(0))
	if NetClient.connected:
		# Serializar solicitudes para evitar que múltiples llamadas simultáneas
		# reutilicen la misma respuesta por proximidad en tiempo.
		while true:
			mutex.lock()
			if not _randf_in_flight:
				_randf_in_flight = true
				mutex.unlock()
				break
			mutex.unlock()
			await randf_available

		var packet:= NetRandF.create(0)
		packet.send(Online.server_peer)
		var res :float = await server_randf_response
		print("[" + str(NetClient.id) + "]", "randf server: ", res)

		mutex.lock()
		_randf_in_flight = false
		mutex.unlock()
		randf_available.emit()
		return res
	else:
		return randf()
	
func manage_randf(packet: NetRandF) -> void:
	# Emitir directamente la respuesta recibida desde el servidor.
	server_randf_response.emit(packet.randf_val)
	
	
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

func manage_force_win_notif(packet: NetForceWinNotif) -> void:
	var tm := GameManager.get_turn_manager()
	if tm == null:
		return

	var cfg := tm.get_game_config()
	if cfg == null or cfg.game_pid != packet.game_pid:
		return

	var user: UserRes = GameManager.get_game_resources().get_res_from_uid(packet.winner_uid, UserRes)
	if user == null:
		tm.finalizar_partida("Jugador %d" % packet.winner_uid)
		return

	var winner_name := user.name.strip_edges()
	if winner_name == "":
		winner_name = str(user.username)

	tm.finalizar_partida(winner_name)

func manage_ping(ping : PingPacket) -> void:
	print("["+str(id)+"] "+"PING: ", ping.message)
