extends Node

var peer_ids: Array[int]

func _ready() -> void:
	Online.on_peer_connected.connect(on_peer_connected)
	Online.on_peer_disconnected.connect(on_peer_disconnected)
	Online.on_server_packet.connect(on_server_packet)


func on_peer_connected(peer_id: int) -> void:
	peer_ids.append(peer_id)

	IDAssignment.create(peer_id).send(Online.client_peers[peer_id])
	print("[Server] enviado IDAssignment ", peer_id)

func on_peer_disconnected(peer_id: int) -> void:
	peer_ids.erase(peer_id)

	# Create IDUnassignment to broadcast to all still connected peers


func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	match data[0]:
		_:
			push_error("Packet type with index ", data[0], " unhandled!")
