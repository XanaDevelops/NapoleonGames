class_name NetForceWinNotif
extends NetPacket

var game_pid: int
var winner_uid: int


static func create(game_id: int, winner_user_uid: int) -> NetForceWinNotif:
	var info := NetForceWinNotif.new()
	info.packet_type = PACKET_TYPE.FORCE_WIN_NOTIF
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.game_pid = game_id
	info.winner_uid = winner_user_uid
	return info


static func create_from_data(data: PackedByteArray) -> NetForceWinNotif:
	var info := NetForceWinNotif.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(9)
	var offset := 1
	data.encode_s32(offset, game_pid)
	offset += 4
	data.encode_u32(offset, winner_uid)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 1
	game_pid = data.decode_s32(offset)
	offset += 4
	winner_uid = data.decode_u32(offset)
