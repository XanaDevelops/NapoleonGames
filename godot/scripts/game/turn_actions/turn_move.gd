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
