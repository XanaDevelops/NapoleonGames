class_name TurnMove
extends TurnAction

# posicion inicial
@export var start_pos : Vector2i
# posicion final
@export var end_pos : Vector2i

static func _static_init() -> void:
	TurnAction.register(ACTION.MOVEMENT, func(data: PackedByteArray) -> TurnMove:
		return TurnMove.create_from_data(data)
	)

static func create(unit: UnitGame, start: Vector2i, end: Vector2i, game_pid: int) -> TurnMove:
	var turn := TurnMove.new()
	turn.action = ACTION.MOVEMENT
	turn.game_pid = game_pid
	turn.player_uid = unit._owner.get_user_res().uid
	turn.unit_uid = unit._cardRes.uid
	turn.start_pos = start
	turn.end_pos = end
	return turn


static func create_from_data(data: PackedByteArray) -> TurnMove:
	var turn := TurnMove.new()
	turn.decode(data)
	return turn

func encode() -> PackedByteArray:
	var data := super.encode()
	var offset := BASE_ENCODE_SIZE
	data.resize(offset + 16)
	data.encode_u32(offset, start_pos.x)
	offset += 4
	data.encode_u32(offset, start_pos.y)
	offset += 4
	data.encode_u32(offset, end_pos.x)
	offset += 4
	data.encode_u32(offset, end_pos.y)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := BASE_ENCODE_SIZE
	var start_x := data.decode_u32(offset)
	offset += 4
	var start_y := data.decode_u32(offset)
	offset += 4
	var end_x := data.decode_u32(offset)
	offset += 4
	var end_y := data.decode_u32(offset)
	start_pos = Vector2i(start_x, start_y)
	end_pos = Vector2i(end_x, end_y)
