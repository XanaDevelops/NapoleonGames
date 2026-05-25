class_name TurnNetResult
extends NetPacket

var is_valid : bool


static func create(valid: bool) -> TurnNetResult:
	var info := TurnNetResult.new()
	info.packet_type = PACKET_TYPE.TURN_RESULT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.is_valid = valid
	return info


static func create_from_data(data: PackedByteArray) -> TurnNetResult:
	var info := TurnNetResult.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(2)
	data.encode_u8(1, 1 if is_valid else 0)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	is_valid = data.decode_u8(1) == 1
