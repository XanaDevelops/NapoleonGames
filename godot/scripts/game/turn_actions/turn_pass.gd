class_name TurnPass
extends TurnAction

static func create(user: UserGame) -> TurnPass:
	var turn := TurnPass.new()
	turn.action = ACTION.PASS_TURN
	turn.player_uid = user.get_user_res().uid
	turn.unit_uid = 0
	return turn
