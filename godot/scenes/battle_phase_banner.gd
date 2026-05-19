extends Control

@export var avatar_p1: TextureRect 
@export var name_p1: Label
@export var units_p1: Label 

@export var avatar_p2: TextureRect 
@export var name_p2: Label 
@export var units_p2: Label 

func paint(user_a: UserGame, user_b: UserGame) -> void:
	var res_a = user_a.get_user_res()
	var res_b = user_b.get_user_res()
	
	avatar_p1.texture = res_a.img
	name_p1.text = res_a.username
	units_p1.text = "%d unidades" % user_a.living_units
	
	avatar_p2.texture = res_b.img
	name_p2.text = res_b.username
	units_p2.text = "%d unidades" % user_b.living_units
