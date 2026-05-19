class_name TurnDeploy
extends TurnAction

var deploy_pos : Vector2i
var card_res : CardRes
var n : int

static func create(player : UserGame, dpos: Vector2i, card_res: CardRes, n: int) -> TurnDeploy:
	var turn := TurnDeploy.new()
	turn.action = ACTION.DEPLOYMENT
	turn.player = player
	turn.deploy_pos = dpos
	turn.card_res = card_res
	turn.n = n
	
	return turn
