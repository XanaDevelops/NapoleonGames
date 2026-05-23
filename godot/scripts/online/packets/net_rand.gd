class_name NetRandF
extends NetPacket


var randf_val : float

static func create(val: float) -> NetRandF:
	var info := NetRandF.new()
	info.packet_type = PACKET_TYPE.RANDF
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.randf_val = val
	return info


static func create_from_data(data: PackedByteArray) -> NetRandF:
	var info := NetRandF.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(5)
	data.encode_float(1, randf_val)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	randf_val = data.decode_float(1)
