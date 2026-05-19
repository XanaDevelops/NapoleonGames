class_name TurnHability
extends TurnAction


# posicion origen
@export var pos: Vector2i
# uid de habilidad
@export var hability_uid: int
# destinos objetivos
@export var dest: Array[Vector2i]

static func _static_init() -> void:
	TurnAction.register(ACTION.ACTIVE, func(data: PackedByteArray) -> TurnHability:
		return TurnHability.create_from_data(data)
	)
	TurnAction.register(ACTION.PASSIVE, func(data: PackedByteArray) -> TurnHability:
		return TurnHability.create_from_data(data)
	)


static func create(unit: UnitGame, pos: Vector2i, hab: HabilityRes, dest: Array[Vector2i]) -> TurnHability:
	var turn := TurnHability.new()
	turn.action = ACTION.PASSIVE if hab.isPassive else ACTION.ACTIVE
	turn.player_uid = unit._owner.get_user_res().uid
	turn.unit_uid = unit._cardRes.uid
	turn.pos = pos
	turn.hability_uid = hab.uid
	turn.dest = dest
	
	return turn


static func create_from_data(data: PackedByteArray) -> TurnHability:
	var turn := TurnHability.new()
	turn.decode(data)
	return turn

func encode() -> PackedByteArray:
	var data := super.encode()
	var offset := BASE_ENCODE_SIZE
	var dest_count := dest.size()
	data.resize(offset + 16 + (dest_count * 8))
	data.encode_u32(offset, pos.x)
	offset += 4
	data.encode_u32(offset, pos.y)
	offset += 4
	data.encode_u32(offset, hability_uid)
	offset += 4
	data.encode_u32(offset, dest_count)
	offset += 4
	for target in dest:
		data.encode_u32(offset, target.x)
		offset += 4
		data.encode_u32(offset, target.y)
		offset += 4
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := BASE_ENCODE_SIZE
	var x := data.decode_u32(offset)
	offset += 4
	var y := data.decode_u32(offset)
	offset += 4
	pos = Vector2i(x, y)
	hability_uid = data.decode_u32(offset)
	offset += 4
	var dest_count := data.decode_u32(offset)
	offset += 4
	dest = []
	for i in dest_count:
		var dest_x := data.decode_u32(offset)
		offset += 4
		var dest_y := data.decode_u32(offset)
		offset += 4
		dest.append(Vector2i(dest_x, dest_y))
