extends Node


signal net_start_game(info: GameConfig)
signal net_end_game(game_pid: int)

class _InnerGameInfo:
	var tm : TurnManager
	var pid_a : int
	var user_a_uid : int
	var pid_b : int
	var user_b_uid: int
	
	func _get_user(pid: int) -> int:
		match pid:
			pid_a:
				return user_a_uid
			pid_b:
				return user_b_uid
			_:
				return -1
	
	func _init(tm : TurnManager, pid_a: int, user_a: int, pid_b: int, user_b: int) -> void:
		self.tm = tm
		self.pid_a = pid_a
		self.user_a_uid = user_a
		self.pid_b = pid_b
		self.user_b_uid = user_b
		
var peer_ids: Array[int]

##Control de randf
var randf_values: Array[float] = []
var randf_indexes: Dictionary[int, int] = {-1: 0}

## Juegos activos
var current_games: Dictionary[int, _InnerGameInfo] = {}

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
	
	## Tema random, clientes nuevos continuan por donde estan el resto
	if not peer_id in randf_indexes:
		# Inicializar el índice del peer en el punto actual de generación
		# para que los clientes nuevos no reciban valores aleatorios ya usados
		var start_idx: int = randf_values.size()
		randf_indexes.set(peer_id, start_idx)
		
	print("[SERVER] ranf_indx: ", randf_indexes)

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
			manage_turn(peer_id, TurnAction.create_from_data(data))
		NetPacket.PACKET_TYPE.RANDF:
			manage_randf(peer_id, NetRandF.create_from_data(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ping(ping : PingPacket) -> void:
	ping.message = "From server: " + ping.message
	_broadcast(ping)
	
	
func manage_randf(pid: int, packet: NetRandF) -> float:
		
	var i := randf_indexes[pid]
	if i >= randf_values.size():
		randf_values.append(randf())
	
	var rand_val := randf_values[i]
	packet.randf_val = rand_val
	randf_indexes[pid] += 1
	print("[SERVER] for: ", pid, " i: ", i, "randf: ", randf_values[i])
	
	# no enviarse al server!
	if pid != -1:
		packet.send(Online.client_peers[pid])
	
	return rand_val
	
func manage_game_request(pid: int, request: OnlineMatchRequest) -> void:
	# Por ahora esto va bien
	var gr := GameManager.get_game_resources()
	
	# Comprobar que no esté en partida
	if current_games.keys().any(
			func(x: int): 
			var _info := current_games[x]
			return _info.pid_a == pid or _info.pid_b == pid or \
				_info.user_a_uid == request.user_uid or _info.user_b_uid == request.user_uid):
		print("[SERVER]", " jugador ya en partida")
		return
		
	if pid in waiting.keys():
		prints("[SERVER]","Cliente ya en espera!")
		return
	
	if waiting.size() >= 1:
		var other_pid := -1

		# Si el jugador busca un amigo concreto, buscar una petición recíproca
		if request.friend_uid != -1:
			print("[SERVER] buscando amigo")
			for key in waiting.keys():
				var w := waiting[key]
				if w.user_uid == request.friend_uid and w.friend_uid == request.user_uid:
					other_pid = key
					break
			if other_pid == -1:
				# No hay petición recíproca: ponerse en espera
				print("[SERVER] no amigo")
				waiting.set(pid, request)
				return
		else:
			print("[SERVER] buscando aleatorio")
			# Petición abierta: emparejar con una petición abierta aleatoria
			var candidates := []
			for key in waiting.keys():
				if waiting[key].friend_uid == -1:
					candidates.append(key)
			if candidates.size() == 0:
				# No hay peticiones abiertas: ponerse en espera
				print("[SERVER] no aleatorio")
				waiting.set(pid, request)
				return
			other_pid = candidates.pick_random()
		var other : OnlineMatchRequest = waiting[other_pid]
		waiting.erase(other_pid)
		var user_a : UserRes = gr.get_res_from_uid(request.user_uid, UserRes)
		var user_b : UserRes = gr.get_res_from_uid(other.user_uid, UserRes)
		var map : MapRes = gr.get_res_from_uid(request.desired_map_uid if randf() <= 0.5 else other.desired_map_uid, MapRes)
		var army_a : ArmyRes = gr.get_res_from_uid(request.army_uid, ArmyRes)
		var army_b : ArmyRes = gr.get_res_from_uid(other.army_uid, ArmyRes)
		
		var game_id := randi_range(0, 0x7fffffff)
		# Seguramente habrá que hacerlo de otra forma, pero por ahora va bien
		GameManager.start_game(user_a, user_b, map, army_a, army_b, true, game_id)
		var tm := GameManager.get_turn_manager()
		
		tm.game_end.connect(manage_end_game, CONNECT_ONE_SHOT)
		
		var lobby := GameLobby.create(game_id, user_a.uid, user_b.uid, army_a.uid, army_b.uid, map.uid)
		lobby.send(Online.client_peers[pid])
		lobby.send(Online.client_peers[other_pid])
		
		current_games.set(game_id, _InnerGameInfo.new(tm, pid, user_a.uid, other_pid, user_b.uid))
		net_start_game.emit(tm.get_game_config())
	else:
		waiting.set(pid, request)
	
func manage_turn(pid: int, turn: TurnAction) -> void:
	var game : _InnerGameInfo = current_games[turn.game_pid]
	if pid != game.pid_a and pid != game.pid_b:
		push_error("pid desconocido")
		return
		
	var other_pid := game.pid_a if pid != game.pid_a else game.pid_b
	# Comprobar que no llega un turno de quien no toca
	if game._get_user(pid) != game.tm.get_current_user()._user_res.uid:
		print("[SERVER] ", game._get_user(pid), " no es su turno, es de ", game.tm.get_current_user()._user_res.uid)
		print("[SERVER] ", game.tm.turn_number, " ", game.tm.turn_order.map(func (x:UserGame): return x._user_res.uid))
		TurnNetResult.create(false).send(Online.client_peers[pid])
		return
		
	var r:= await game.tm.replay_turn(turn)
	print("[SERVER] turn ", "ok" if r else "nope")
	var res := TurnNetResult.create(r)
	if r:
		turn.send(Online.client_peers[other_pid])
	res.send(Online.client_peers[pid])
	
	
	
func manage_end_game(game_pid: int) -> void:
	if current_games.erase(game_pid):
		net_end_game.emit(game_pid)
		print("[SERVER] partida ", game_pid, " finalizada")
		
func _broadcast(packet : NetPacket) -> void:
	Online.connection.broadcast(0, packet.encode(), packet.flag)
