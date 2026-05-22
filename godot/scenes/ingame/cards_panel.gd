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

	if tile_info:
		tile_info.visible = false
	if UnitPanel:
		UnitPanel.visible= false
	if confirm_dialog:
		confirm_dialog.visible= false
		confirm_dialog.confirmed.connect(_on_use_hability_confirmed)
		confirm_dialog.cancelled.connect(_on_use_hability_cancelled)	

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
