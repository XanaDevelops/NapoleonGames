class_name GameLobby
extends NetPacket


var game_pid : int

var user_a_uid: int
var user_b_uid: int
var army_a_uid: int
var army_b_uid: int
var map_res_uid: int


static func create(game_id: int, user_a_id: int, user_b_id: int, army_a_id: int, army_b_id: int, map_uid: int) -> GameLobby:
	var info := GameLobby.new()
	info.packet_type = PACKET_TYPE.SET_GAME_LOBBY
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.game_pid = game_id
	info.user_a_uid = user_a_id
	info.user_b_uid = user_b_id
	info.army_a_uid = army_a_id
	info.army_b_uid = army_b_id
	info.map_res_uid = map_uid
	return info


static func create_from_data(data: PackedByteArray) -> GameLobby:
	var info := GameLobby.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(25)
	var offset := 1
	data.encode_s32(offset, game_pid)
	offset += 4
	data.encode_u32(offset, user_a_uid)
	offset += 4
	data.encode_u32(offset, user_b_uid)
	offset += 4
	data.encode_u32(offset, army_a_uid)
	offset += 4
	data.encode_u32(offset, army_b_uid)
	offset += 4
	data.encode_u32(offset, map_res_uid)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 1
	game_pid = data.decode_s32(offset)
	offset += 4
	user_a_uid = data.decode_u32(offset)
	offset += 4
	user_b_uid = data.decode_u32(offset)
	offset += 4
	army_a_uid = data.decode_u32(offset)
	offset += 4
	army_b_uid = data.decode_u32(offset)
	offset += 4
	map_res_uid = data.decode_u32(offset)
