extends Control

@onready var tile_info: Control  = $MarginContainer/TabContainer/TileInfo
@onready var unit_info: Control  = $MarginContainer/TabContainer/UnitInfo
@onready var tabs: TabContainer  = $MarginContainer/TabContainer
@onready var deployment_box: HBoxContainer = $MarginContainer/DeploymentBox

var _confirm_dialog: AcceptDialog = null


var is_deployment_active: bool = false


signal confirmed
signal cancelled

func _ready() -> void:
	await get_tree().process_frame
	_setup_pages()
	

func _setup_pages() -> void:
	tile_info.custom_minimum_size = Vector2(size.x, size.y)
	unit_info.custom_minimum_size = Vector2(size.x, size.y)

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
		_objective_text(hab.objective),
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

func _objective_text(objective: HabilityRes.HAB_DEST) -> String:
	match objective:
		HabilityRes.HAB_DEST.SELF:         return "Uno mismo"
		HabilityRes.HAB_DEST.SINGLE_ENEMY: return "Enemigo único"
		HabilityRes.HAB_DEST.SINGLE_ALLY:  return "Aliado único"
		HabilityRes.HAB_DEST.SINGLE_ANY:   return "Cualquier único"
		HabilityRes.HAB_DEST.EVERYONE:     return "Todos en rango"
		_:                                 return "Desconocido"

func set_deployment_phase(is_active: bool) -> void:
	is_deployment_active = is_active
	tabs.visible = not is_active
	if deployment_box:
		deployment_box.visible = is_active
