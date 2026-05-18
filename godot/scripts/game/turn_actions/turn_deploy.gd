class_name TurnDeploy
extends TurnAction

var deploy_pos : Vector2i
var card_uid : int
var n : int

static func create(player : UserGame, dpos: Vector2i, card_res: CardRes, n: int) -> TurnDeploy:
	var turn := TurnDeploy.new()
	turn.action = ACTION.DEPLOYMENT
	turn.player = player
	turn.deploy_pos = dpos
	turn.card_uid = card_res.uid
	turn.n = n
	
	return turn

func encode() -> PackedByteArray:
	var data := super.encode()
	var offset := 2
	data.resize(offset + 16)
	data.encode_s32(offset, deploy_pos.x)
	offset += 4
	data.encode_s32(offset, deploy_pos.y)
	offset += 4
	data.encode_s32(offset, card_uid)
	offset += 4
	data.encode_s32(offset, n)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	var offset := 2
	var x := data.decode_s32(offset)
	offset += 4
	var y := data.decode_s32(offset)
	offset += 4
	deploy_pos = Vector2i(x, y)
	card_uid = data.decode_s32(offset)
	offset += 4
	n = data.decode_s32(offset)
