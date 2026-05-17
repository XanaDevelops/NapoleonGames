class_name PingPacket
extends NetPacket

var sender_id : int
var message : String


static func create(id: int, text: String) -> PingPacket:
	var info:= PingPacket.new()
	info.packet_type = PACKET_TYPE.PING
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.sender_id = id
	info.message = text
	return info


static func create_from_data(data: PackedByteArray) -> PingPacket:
	var info:= PingPacket.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(2)
	data.encode_u8(1, sender_id)
	data.append_array(message.to_utf8_buffer())

	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	sender_id = data.decode_u8(1)
	message = data.slice(2).get_string_from_utf8()
	
	
	
	
