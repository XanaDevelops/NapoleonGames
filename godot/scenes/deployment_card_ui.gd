extends Button

@onready var name_label: Label = $VBoxContainer/Name
@onready var unit_texture: TextureRect = $ImageCard
@onready var amount_label: Label = $VBoxContainer/Quantity


var army_group: CardArmyGroup

func setup(p_army_group: CardArmyGroup) -> void:
	army_group = p_army_group
	name_label.text = army_group.cardType.name
	amount_label.text = "x" + str(army_group.n)
	unit_texture.texture=army_group.cardType.img

func set_selected_visual(is_selected: bool) -> void:
	if is_selected:
		
		modulate = Color(0.7, 1.2, 0.7) 
	else:
		modulate = Color(1, 1, 1) 
