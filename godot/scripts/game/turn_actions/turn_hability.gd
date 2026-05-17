class_name TurnHability
extends TurnAction


var pos: Vector2i
var hability: HabilityRes
var dest: Array[Vector2i]


static func create(unit: UnitGame, pos: Vector2i, hab: HabilityRes, dest: Array[Vector2i]) -> TurnHability:
	var turn := TurnHability.new()
	turn.action = ACTION.PASSIVE if hab.isPassive else ACTION.ACTIVE
	turn.player = unit._owner
	turn.unit = unit
	turn.pos = pos
	turn.dest = dest
	
	return turn
