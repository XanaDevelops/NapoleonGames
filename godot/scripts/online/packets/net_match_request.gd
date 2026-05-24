class_name OnlineMatchRequest
extends NetPacket

var user_uid : int
var army_uid : int
var desired_map_uid: int
var friend_uid: int

static func create(user_uid: int, army_id: int, map_uid: int, friend_uid := -1) -> OnlineMatchRequest:
	var info := OnlineMatchRequest.new()
	info.packet_type = PACKET_TYPE.REQUEST_ONLINE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.user_uid = user_uid
	info.army_uid = army_id
	info.desired_map_uid = map_uid
	info.friend_uid = friend_uid
	return info


static func create_from_data(data: PackedByteArray) -> OnlineMatchRequest:
	var info := OnlineMatchRequest.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	# 1 byte packet_type + 4 * 4 bytes (u32/u32/u32/s32) = 17 bytes
	data.resize(17)
	var offset := 1
	data.encode_u32(offset, user_uid)
	offset += 4
	data.encode_u32(offset, army_uid)
	offset += 4
	data.encode_u32(offset, desired_map_uid)
	offset += 4
	data.encode_s32(offset, friend_uid)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 1
	user_uid = data.decode_u32(offset)
	offset += 4
	army_uid = data.decode_u32(offset)
	offset += 4
	desired_map_uid = data.decode_u32(offset)
	offset += 4
	friend_uid = data.decode_s32(offset)
