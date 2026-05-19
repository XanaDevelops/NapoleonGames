extends Node

signal handle_local_id_assignment(local_id: int)

var id: int = -1

func _ready() -> void:
	Online.on_client_packet.connect(on_client_packet)


func on_client_packet(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		NetPacket.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))
		NetPacket.PACKET_TYPE.PING:
			manage_ping(PingPacket.create_from_data(data))
		NetPacket.PACKET_TYPE.SET_GAME_LOBBY:
			GameLobby.create_from_data(data)
			pass
		NetPacket.PACKET_TYPE.TURN_ACTION:
			pass
		_:
			push_error("Packet type with index ", data[0], " unhandled!")


func manage_ids(id_assignment: IDAssignment) -> void:
	if id == -1: # When id == -1, the id sent by the server is for us
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id)

	prints("my id", id)


func manage_ping(ping : PingPacket) -> void:
	print("["+str(id)+"] "+"PING: ", ping.message)
