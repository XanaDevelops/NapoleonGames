class_name CircularEndTurn
extends Control

@export var label: Label 
@export var boton:Button
var turn_manager: TurnManager

func _ready() -> void:
	visible = false
	boton.pressed.connect(_end_turn)
	await get_tree().process_frame
	_connect_turn_manager()


func _connect_turn_manager() -> void:
	var tm := GameManager.get_turn_manager()
	if tm == null:
		return

	turn_manager = tm
	if not tm.ui_setup_requested.is_connected(_on_ui_setup_requested):
		tm.ui_setup_requested.connect(_on_ui_setup_requested)
	if not tm.combat_phase_started.is_connected(show_battle):
		tm.combat_phase_started.connect(show_battle)
	if not tm.deployment_phase_started.is_connected(show_deployment):
		tm.deployment_phase_started.connect(show_deployment)
	if not tm.tick_turn.is_connected(_update_button_state):
		tm.tick_turn.connect(_update_button_state)

	_update_button_state()


func _on_ui_setup_requested(tm: TurnManager) -> void:
	turn_manager = tm
	_update_button_state()


func show_battle(_ignore: String) -> void:
	visible = true
	_update_button_state()


func show_deployment(_ignore: String) -> void:
	visible = false


func _update_button_state() -> void:
	if turn_manager == null:
		turn_manager = GameManager.get_turn_manager()
	if turn_manager == null:
		return

	boton.disabled = not turn_manager.is_current_user_local()
	boton.self_modulate = Color(0.72, 0.72, 0.72, 1) if boton.disabled else Color(1, 1, 1, 1)


func _end_turn() -> void:
	GameManager.get_turn_manager().advance_turn()
