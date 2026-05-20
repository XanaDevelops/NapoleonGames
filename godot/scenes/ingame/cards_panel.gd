extends Control

@onready var tile_info: Control  = $MarginContainer/TabContainer/TileInfo
@onready var unit_info: Control  = $MarginContainer/TabContainer/UnitInfo
@onready var tabs: TabContainer  = $MarginContainer/TabContainer
@onready var deployment_box: HBoxContainer = $MarginContainer/DeploymentBox

var _confirm_dialog: AcceptDialog = null


var is_deployment_active: bool =false



signal confirmed
signal cancelled

func _ready() -> void:
	await get_tree().process_frame
	_setup_pages()
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
		_on_deployment_phase_started()


func _on_deployment_phase_started() -> void:
	set_deployment_phase(true)


func _on_battle_phase_started() -> void:
	set_deployment_phase(false)


func _on_unit_info_cleared() -> void:
	clear_unit_info()
	

func _setup_pages() -> void:
	
	tile_info.custom_minimum_size = Vector2(size.x, size.y)
	unit_info.custom_minimum_size = Vector2(size.x, size.y)

#func set_phase_battle() -> void:
	#clear()
	#deployment_box.visible= false
	
#func set_phase_deployment() -> void:
	#tabs.visible= false
	#deployment_box.visible= true
	#
func paint_tile_info(tile: TileGame) -> void:
	
	if is_deployment_active: 
		return 
	
	
	tabs.visible = true
	tile_info.paint(tile)
	tabs.set_tab_hidden(1, true)
	tabs.current_tab = 0

func paint_unit_info(tile: TileGame) -> void:
	
	if is_deployment_active: 
		return 
	
	
	tabs.visible = true
	unit_info.paint(tile)
	tabs.set_tab_hidden(1, false)
	tabs.current_tab = 0

func clear_unit_info() -> void:
	tabs.set_tab_hidden(1, true)

func clear() -> void:
	tabs.visible = false

func show_confirm_dialog(hab: HabilityRes, targets: Array[Vector2i], _unit: UnitGame) -> void:
	_confirm_dialog = AcceptDialog.new()
	_confirm_dialog.title       = hab.name
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
	
func set_deployment_phase(is_active: bool) -> void:
	is_deployment_active = is_active
	tabs.visible = !is_active
	if deployment_box:
		deployment_box.visible = is_active


#func populate_deployment(army_groups: Array) -> void:
	#deployment_box.populate(army_groups)
#
#func remove_deployment_card(group: CardArmyGroup) -> void:
	#deployment_box.remove_card_visual(group)
