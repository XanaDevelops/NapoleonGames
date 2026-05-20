class_name TurnDeploy
extends TurnAction

# posicion de despliegue
@export var deploy_pos : Vector2i
# cantidad de unidades
@export var n : int

static func create(player : UserGame, dpos: Vector2i, card_res: CardRes, n: int) -> TurnDeploy:
	var turn := TurnDeploy.new()
	turn.action = ACTION.DEPLOYMENT
	turn.player_uid = player.get_user_res().uid
	turn.unit_uid = card_res.uid
	turn.deploy_pos = dpos
	turn.n = n
	
	return turn

func encode() -> PackedByteArray:
	var data := super.encode()
	var offset := BASE_ENCODE_SIZE
	data.resize(offset + 12)
	data.encode_s32(offset, deploy_pos.x)
	offset += 4
	data.encode_s32(offset, deploy_pos.y)
	offset += 4
	data.encode_s32(offset, n)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := BASE_ENCODE_SIZE
	var x := data.decode_s32(offset)
	offset += 4
	var y := data.decode_s32(offset)
	offset += 4
	deploy_pos = Vector2i(x, y)
	n = data.decode_s32(offset)
