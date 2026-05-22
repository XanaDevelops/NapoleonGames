class_name GameConfig
extends Resource

@export var user_a: UserRes
@export var user_b: UserRes
@export var army_a: ArmyRes
@export var army_b: ArmyRes
@export var map_res: MapRes

func _init(p_user_a: UserRes = null, p_user_b: UserRes = null, p_map_res: MapRes = null, p_army_a: ArmyRes = null, p_army_b: ArmyRes = null) -> void:
	user_a = p_user_a
	user_b = p_user_b
	army_a = p_army_a
	army_b = p_army_b
	map_res = p_map_res
