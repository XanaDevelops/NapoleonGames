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

const BASE_ENCODE_SIZE := 18

static var _registry: Dictionary[ACTION, Callable] = {}

static func register(action_type: ACTION, ctor: Callable) -> void:
	_registry[action_type] = ctor

static func create_from_data(data: PackedByteArray) -> TurnAction:
	var action_value := data.decode_u8(1)

	if not _registry.has(action_value):
		push_error("Unhandled TurnAction action: %s" % str(action_value))
		return null
	return _registry[action_value].call(data)

# orden de acción
@export var action_order: int
# pid de la partida
@export var game_pid: int = -1
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
	data.encode_s32(2, game_pid)
	data.encode_u32(6, player_uid)
	data.encode_u32(10, unit_uid)
	data.encode_u32(14, action_order)
	return data


# Override function in derived classes
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	action = data.decode_u8(1)
	game_pid = data.decode_s32(2)
	player_uid = data.decode_u32(6)
	unit_uid = data.decode_u32(10)
	action_order = data.decode_u32(14)

func _init() -> void:
	packet_type = PACKET_TYPE.TURN_ACTION
	flag = ENetPacketPeer.FLAG_RELIABLE
