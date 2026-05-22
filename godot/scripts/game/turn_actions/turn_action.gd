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

const BASE_ENCODE_SIZE := 14

# orden de acción
@export var action_order: int
# uid del usuario
@export var player_uid: int
# tipo de accion
@export var action: ACTION
# uid de la carta/unidad
# duplicate no funciona si _init(..args), en teoria lo que nos hace falta no cambia
@export var unit_uid: int

# Override function in derived classes
func encode() -> PackedByteArray:
	var data := super.encode()
	data.resize(BASE_ENCODE_SIZE)
	data.encode_u8(1, action)
	data.encode_s32(2, player_uid)
	data.encode_s32(6, unit_uid)
	data.encode_s32(10, action_order)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	action = data.decode_u8(1)
	player_uid = data.decode_s32(2)
	unit_uid = data.decode_s32(6)
	action_order = data.decode_s32(10)

func _init() -> void:
	pass
