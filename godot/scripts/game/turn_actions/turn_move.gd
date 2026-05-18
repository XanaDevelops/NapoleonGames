class_name TurnMove
extends TurnAction

var start_pos : Vector2i
var end_pos : Vector2i

static func create(unit: UnitGame, start: Vector2i, end: Vector2i) -> TurnMove:
	var turn := TurnMove.new()
	turn.action = ACTION.MOVEMENT
	turn.player = unit._owner
	turn.unit = unit
	turn.start_pos = start
	turn.end_pos = end
	return turn

func encode() -> PackedByteArray:
	var data := super.encode()
	var offset := 2
	data.resize(offset + 16)
	data.encode_s32(offset, start_pos.x)
	offset += 4
	data.encode_s32(offset, start_pos.y)
	offset += 4
	data.encode_s32(offset, end_pos.x)
	offset += 4
	data.encode_s32(offset, end_pos.y)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 2
	var start_x := data.decode_s32(offset)
	offset += 4
	var start_y := data.decode_s32(offset)
	offset += 4
	var end_x := data.decode_s32(offset)
	offset += 4
	var end_y := data.decode_s32(offset)
	start_pos = Vector2i(start_x, start_y)
	end_pos = Vector2i(end_x, end_y)
