extends HBoxContainer

signal unit_selected_for_deployment(group: CardArmyGroup)

const DEPLOYMENT_CARD_SCENE = preload("res://scenes/deployment_card_ui.tscn")

var selected_card: Button = null

func populate(army_groups: Array) -> void:
	_clear_all()
	for group: CardArmyGroup in army_groups:
		var card := DEPLOYMENT_CARD_SCENE.instantiate() as Button
		add_child(card)
		
		card.set_meta("army_group", group)
		card.setup(group)
		card.pressed.connect(_on_card_pressed.bind(card, group))

func _on_card_pressed(card_node: Button, group: CardArmyGroup) -> void:
	if is_instance_valid(selected_card):
		selected_card.set_selected_visual(false)
		
	selected_card = card_node
	selected_card.set_selected_visual(true)
	unit_selected_for_deployment.emit(group)

func remove_card_visual(group: CardArmyGroup) -> void:
	for child in get_children():
		if child.get_meta("army_group", null) == group:
			if selected_card == child:
				selected_card = null
			child.queue_free()
			return

func _clear_all() -> void:
	for child in get_children():
		child.queue_free()
	selected_card = null
