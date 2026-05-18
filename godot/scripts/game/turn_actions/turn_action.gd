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

# uid del usuario
var player_uid: int
# tipo de accion
var action: ACTION
# uid de la carta/unidad
## duplicate no funciona si _init(..args), en teoria lo que nos hace falta no cambia
var unit_uid: int

# Override function in derived classes
func encode() -> PackedByteArray:
	var data := super.encode()
	data.resize(10)
	data.encode_u8(1, action)
	data.encode_s32(2, player_uid)
	data.encode_s32(6, unit_uid)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	action = data.decode_u8(1)
	player_uid = data.decode_s32(2)
	unit_uid = data.decode_s32(6)

func _init() -> void:
	pass
