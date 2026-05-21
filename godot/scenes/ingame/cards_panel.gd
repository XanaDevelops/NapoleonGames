extends Control

@export var deployment_box: HBoxContainer
@export var tile_info: Control      
@export var deployment_panel: Panel
@export var UnitPanel: PanelContainer
var _confirm_dialog: AcceptDialog = null
var is_deployment_active: bool = false

signal confirmed
signal cancelled

func _ready() -> void:
	await get_tree().process_frame
	_connect_turn_manager()


func _connect_turn_manager() -> void:
	var turn_manager: TurnManager = GameManager.get_turn_manager()
	if turn_manager == null:
		print("[CardsPanel] TurnManager not ready")
		return
	print("[CardsPanel] TurnManager connected")

	if not turn_manager.deployment_phase_started.is_connected(_on_deployment_phase_started):
		turn_manager.deployment_phase_started.connect(_on_deployment_phase_started)
	if not turn_manager.battle_phase_started.is_connected(_on_battle_phase_started):
		turn_manager.battle_phase_started.connect(_on_battle_phase_started)
	if not turn_manager.unit_info_cleared.is_connected(_on_unit_info_cleared):
		turn_manager.unit_info_cleared.connect(_on_unit_info_cleared)
	if turn_manager.is_deployment_phase:
		print("[CardsPanel] Forcing deployment phase UI")
		_on_deployment_phase_started("")

	if tile_info:
		tile_info.visible = false
	if UnitPanel:
		UnitPanel.visible= false

func _on_deployment_phase_started(_playerName: String) -> void:
	set_deployment_phase(true)


func _on_battle_phase_started() -> void:
	set_deployment_phase(false)


func _on_unit_info_cleared() -> void:
	clear_unit_info()
	

func paint_tile_info(tile: TileGame) -> void:
	if is_deployment_active:
		return
	if tile_info:
		tile_info.visible = true
		tile_info.paint(tile)

func paint_unit_info(tile: TileGame) -> void:
	if is_deployment_active:
		return
	if UnitPanel:
		UnitPanel.visible = true
		UnitPanel.paint(tile)
		
		
func clear_unit_info() -> void:
	if UnitPanel:
		UnitPanel.visible = false
		pass

func clear() -> void:
	if tile_info:
		tile_info.visible = false
	if UnitPanel:
		UnitPanel.visible = false

func set_deployment_phase(is_active: bool) -> void:
	is_deployment_active = is_active
	if deployment_box:
		#deployment_box.visible = is_active
		deployment_panel.visible= is_active
	if is_active:
		clear()

func show_confirm_dialog(hab: HabilityRes, targets: Array[Vector2i], _unit: UnitGame) -> void:
	_confirm_dialog = AcceptDialog.new()
	_confirm_dialog.title = hab.name
	_confirm_dialog.dialog_text = "Descripción: %s\nObjetivo: %s\nManá: %d\nRango: %d\nCD: %dt\nPasiva: %s" % [
		hab.desc,
		hab._objective_text(),
		hab.manaCost,
		hab.radius,
		hab.cooldown,
		"Sí" if hab.isPassive else "No",
	]
	_confirm_dialog.add_cancel_button("Cancelar")
	add_child(_confirm_dialog)
	_confirm_dialog.popup_centered()
	_confirm_dialog.confirmed.connect(_on_dialog_confirmed)
	_confirm_dialog.canceled.connect(_on_dialog_cancelled)

func hide_confirm_dialog() -> void:
	if _confirm_dialog == null:
		return
	_confirm_dialog.queue_free()
	_confirm_dialog = null

func _on_dialog_confirmed() -> void:
	hide_confirm_dialog()
	emit_signal("confirmed")

func _on_dialog_cancelled() -> void:
	hide_confirm_dialog()
	emit_signal("cancelled")
