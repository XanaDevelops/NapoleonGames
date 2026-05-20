extends HBoxContainer

signal unit_selected_for_deployment(group: CardArmyGroup)

const DEPLOYMENT_CARD_SCENE = preload("res://scenes/deployment_card_ui.tscn")

var selected_card: Button = null

func _ready() -> void:
	await get_tree().process_frame
	_connect_turn_manager()


func _connect_turn_manager() -> void:
	var turn_manager: TurnManager = GameManager.get_turn_manager()
	if turn_manager == null:
		print("[DeploymentBox] TurnManager not ready")
		return

	if not turn_manager.deployment_data_refreshed.is_connected(_on_deployment_data_refreshed):
		turn_manager.deployment_data_refreshed.connect(_on_deployment_data_refreshed)
	if not turn_manager.deployment_card_consumed.is_connected(_on_deployment_card_consumed):
		turn_manager.deployment_card_consumed.connect(_on_deployment_card_consumed)
	if turn_manager.is_deployment_phase:
		print("[DeploymentBox] Forcing initial deployment data")
		_on_deployment_data_refreshed(turn_manager.get_current_user().deployment_data)


func _on_deployment_data_refreshed(groups: Array) -> void:
	populate(groups)


func _on_deployment_card_consumed(group: CardArmyGroup) -> void:
	remove_card_visual(group)

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
