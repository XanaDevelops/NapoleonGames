class_name TurnPass
extends TurnAction

static func _static_init() -> void:
	TurnAction.register(ACTION.PASS_TURN, func(data: PackedByteArray) -> TurnPass:
		return TurnPass.create_from_data(data)
	)

static func create(user: UserGame) -> TurnPass:
	var turn := TurnPass.new()
	turn.action = ACTION.PASS_TURN
	turn.player_uid = user.get_user_res().uid
	turn.unit_uid = 0
	return turn


static func create_from_data(data: PackedByteArray) -> TurnPass:
	var turn := TurnPass.new()
	turn.decode(data)
	return turn
