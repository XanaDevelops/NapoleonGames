extends GutTest

var _server: Node
var _client: Node
var _server_peer_id := -1
var _client_connected := false
var _server_received: Array[PackedByteArray] = []
var _client_received: Array[PackedByteArray] = []

func before_all() -> void:
	if Online.on_client_packet.is_connected(NetClient.on_client_packet):
		Online.on_client_packet.disconnect(NetClient.on_client_packet)
	if Online.on_peer_connected.is_connected(NetServer.on_peer_connected):
		Online.on_peer_connected.disconnect(NetServer.on_peer_connected)
	if Online.on_peer_disconnected.is_connected(NetServer.on_peer_disconnected):
		Online.on_peer_disconnected.disconnect(NetServer.on_peer_disconnected)
	if Online.on_server_packet.is_connected(NetServer.on_server_packet):
		Online.on_server_packet.disconnect(NetServer.on_server_packet)
	_server = Online.get_script().new()
	_client = Online.get_script().new()
	add_child_autoqfree(_server)
	add_child_autoqfree(_client)
	_server.on_peer_connected.connect(_on_server_peer_connected)
	_server.on_server_packet.connect(_on_server_packet)
	_client.on_connected_to_server.connect(_on_client_connected)
	_client.on_client_packet.connect(_on_client_packet)
	assert_true(_server.start_server(), "Server should start")
	assert_true(_client.start_client(), "Client should start")


func test_all_net_packets_round_trip() -> void:
	await _wait_for_connection()
	_server_received.clear()
	_client_received.clear()

	var id_packet := IDAssignment.create(7)
	await _send_server_to_client_and_assert(id_packet, "IDAssignment")

	var lobby_packet := GameLobby.create(100, 1, 2, 3, 4, 5)
	await _send_server_to_client_and_assert(lobby_packet, "GameLobby")

	var match_packet := OnlineMatchRequest.create(11, 22, 33)
	await _send_client_to_server_and_assert(match_packet, "OnlineMatchRequest")

	var ping_packet := PingPacket.create(9, "hello")
	await _send_client_to_server_and_assert(ping_packet, "PingPacket")

	var user_res := UserRes.new()
	user_res.uid = 42
	var user_game := UserGame.new(user_res)
	var card_res := CardRes.new()
	card_res.uid = 99
	card_res.hp = 10
	card_res.mana = 5
	card_res.habilities = []
	var unit := UnitGame.new(card_res, user_game)
	var turn_packet := TurnMove.create(unit, Vector2i(1, 2), Vector2i(3, 4))
	turn_packet.packet_type = NetPacket.PACKET_TYPE.TURN_ACTION
	turn_packet.flag = ENetPacketPeer.FLAG_RELIABLE
	turn_packet.action_order = 3
	await _send_client_to_server_and_assert(turn_packet, "TurnMove")


func _wait_for_connection() -> void:
	await wait_until(func(): return _client_connected and _server_peer_id != -1, 5)


func _send_server_to_client_and_assert(packet: NetPacket, label: String) -> void:
	var start_count := _client_received.size()
	packet.send(_server.client_peers[_server_peer_id])
	await wait_until(func(): return _client_received.size() > start_count, 2)
	_assert_packet_round_trip(packet, _client_received.back(), label)


func _send_client_to_server_and_assert(packet: NetPacket, label: String) -> void:
	var start_count := _server_received.size()
	packet.send(_client.server_peer)
	await wait_until(func(): return _server_received.size() > start_count, 2)
	_assert_packet_round_trip(packet, _server_received.back(), label)


func _assert_packet_round_trip(packet: NetPacket, data: PackedByteArray, label: String) -> void:
	var expected := packet.encode()
	_assert_packed_bytes_eq(expected, data, label + " raw")
	var decoded := _decode_packet(data)
	assert_not_null(decoded, label + " decode")
	if decoded != null:
		_assert_packed_bytes_eq(decoded.encode(), expected, label + " decoded")


func _assert_packed_bytes_eq(a: PackedByteArray, b: PackedByteArray, label: String) -> void:
	assert_eq(a.size(), b.size(), label + " size")
	var count := mini(a.size(), b.size())
	for i in range(count):
		assert_eq(a[i], b[i], label + " byte " + str(i))


func _decode_packet(data: PackedByteArray) -> NetPacket:
	var packet_type := data.decode_u8(0)
	match packet_type:
		NetPacket.PACKET_TYPE.ID_ASSIGNMENT:
			return IDAssignment.create_from_data(data)
		NetPacket.PACKET_TYPE.REQUEST_ONLINE:
			return OnlineMatchRequest.create_from_data(data)
		NetPacket.PACKET_TYPE.SET_GAME_LOBBY:
			return GameLobby.create_from_data(data)
		NetPacket.PACKET_TYPE.TURN_ACTION:
			return TurnMove.create_from_data(data)
		NetPacket.PACKET_TYPE.PING:
			return PingPacket.create_from_data(data)
		_:
			return null


func _on_server_peer_connected(peer_id: int) -> void:
	_server_peer_id = peer_id


func _on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	_server_received.append(data)


func _on_client_connected() -> void:
	_client_connected = true


func _on_client_packet(data: PackedByteArray) -> void:
	_client_received.append(data)
