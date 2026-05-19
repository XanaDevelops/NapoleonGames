class_name OnlineMatchRequest
extends NetPacket

var requester_pid : int
var army_uid : int
var desired_map_uid: int


static func create(requester_id: int, army_id: int, map_uid: int) -> OnlineMatchRequest:
	var info := OnlineMatchRequest.new()
	info.packet_type = PACKET_TYPE.REQUEST_ONLINE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.requester_pid = requester_id
	info.army_uid = army_id
	info.desired_map_uid = map_uid
	return info


static func create_from_data(data: PackedByteArray) -> OnlineMatchRequest:
	var info := OnlineMatchRequest.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(13)
	var offset := 1
	data.encode_s32(offset, requester_pid)
	offset += 4
	data.encode_s32(offset, army_uid)
	offset += 4
	data.encode_s32(offset, desired_map_uid)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 1
	requester_pid = data.decode_s32(offset)
	offset += 4
	army_uid = data.decode_s32(offset)
	offset += 4
	desired_map_uid = data.decode_s32(offset)
