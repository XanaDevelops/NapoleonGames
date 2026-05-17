@abstract
class_name TurnAction
extends NetPacket


enum ACTION {
	MOVEMENT, #movimiento
	ACTIVE,   #uso de habilidad activa
	PASSIVE,   #activacion de habilidad pasiva
	ALTER_STATE, #activación de un estado alterado
	DEPLOYMENT, 
	PASS_TURN
}

var player: UserGame
var action: ACTION
## duplicate no funciona si _init(..args), en teoria lo que nos hace falta no cambia
var unit: UnitGame

# Override function in derived classes
func encode() -> PackedByteArray:
	var data := super.encode()
	data.encode_u8(1, action)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	packet_type = data.decode_u8(0)
	action = data.decode_u8(1)

func _init() -> void:
	pass
