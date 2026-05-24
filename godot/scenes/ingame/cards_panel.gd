extends Control

@export var deployment_box: HBoxContainer
@export var tile_info: Control      
@export var deployment_panel: Panel
@export var UnitPanel: PanelContainer
var confirm_dialog: Control
var is_deployment_active: bool = false

signal confirmed
signal cancelled

func _ready() -> void:
	confirm_dialog= preload("res://scenes/hability_dialog.tscn").instantiate()
	get_tree().root.add_child(confirm_dialog)
	await get_tree().process_frame
	confirm_dialog.global_position = (get_viewport_rect().size - confirm_dialog.size) / 2.0

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
	if confirm_dialog:
		confirm_dialog.visible= false
		confirm_dialog.confirmed.connect(_on_use_hability_confirmed)
		confirm_dialog.cancelled.connect(_on_use_hability_cancelled)
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
		deployment_panel.visible= is_active
	if is_active:
		clear()

func show_confirm_dialog(hab: HabilityRes, targets: Array[Vector2i], unit: UnitGame) -> void:
	if confirm_dialog==null:
		return
	confirm_dialog.paint(hab, unit, targets)
	confirm_dialog.visible= true

func hide_confirm_dialog() -> void:
	if confirm_dialog == null:
		return
	confirm_dialog.visible= false

func _on_use_hability_cancelled()-> void:
	cancelled.emit()
	confirm_dialog.visible= false
func _on_use_hability_confirmed()-> void:
	confirmed.emit()
	confirm_dialog.visible= false
