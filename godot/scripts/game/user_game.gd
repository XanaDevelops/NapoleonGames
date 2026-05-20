class_name UserGame
extends RuntimeResource

var _user_res : UserRes
var deployment_data: Array[CardArmyGroup] = []
var living_units: int = 0

var _is_remote_user := false

func _init(user : UserRes) -> void:
	_user_res = user

func get_user_res() -> UserRes:
	return _user_res

func set_deployment_data(groups: Array[CardArmyGroup]) -> void:
	deployment_data = groups

func has_deployment_cards() -> bool:
	return not deployment_data.is_empty()

func get_deployment_count() -> int:
	return deployment_data.size()

func consume_deployment_group(group: CardArmyGroup) -> bool:
	if deployment_data.has(group):
		deployment_data.erase(group)
		return true
	return false

func add_living_units(count: int) -> void:
	living_units += count

func dec_living_units(count: int) -> void:
	living_units = maxi(0, living_units - count)
