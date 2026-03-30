class_name CardArmyGroup
extends GameResource


@export var cardType : CardRes
@export var n: int


func get_weight() -> int:
	return cardType.weight * n
