extends PanelContainer



@export var unit_label: Label
@export var unit_texture: TextureRect

@export var owner_label: Label
@export  var speed_label: Label
@export var dodge_label: Label
@export var habilities_grid: GridContainer
@export var current_mana: ProgressBar
@export var descriptionButton:Button

@export var unit_info: PanelContainer
var _desc_handler: DescriptionButtonHandler

@export var currrentAlterStates_container: PanelContainer
@export var alter_states_grid: GridContainer

signal hability_use_requested(hab: HabilityRes)
# UnitInfo
var _observed_unit: UnitGame = null
func _ready() -> void:
	await get_tree().process_frame



func paint(tile: TileGame) -> void:
	if _observed_unit != null:
		if _observed_unit.mana_changed.is_connected(_on_mana_changed):
			_observed_unit.mana_changed.disconnect(_on_mana_changed)
	self.unit_label.text =tile.get_unit_name()
	self.owner_label.text = str(tile.get_owner_name())
	self.unit_texture.texture= tile.get_unit_portrait()
	self.speed_label.text = str(tile.get_speed())
	self.dodge_label.text = str(tile.get_dodge())
	_desc_handler = DescriptionButtonHandler.new()
	_desc_handler.setup(
		descriptionButton,
		unit_info,
		func(): return tile.get_unit_desc()
	)

	paint_habilities(tile.get_habilities(),tile.get_availableHabilities())
	paint_AlterStates(tile.get_AlterStates())
	var unit := tile.get_unit()
	if unit != null:
			_observed_unit = unit
			current_mana.init(unit._cardRes.mana)
			current_mana.set_value_silent(unit.mana)
			unit.mana_changed.connect(_on_mana_changed)
			
func paint_habilities(habilities: Array[HabilityRes], available_habilities: Dictionary[HabilityRes, int]) -> void:
	if habilities== null:
		return
	for child in habilities_grid.get_children():
		child.queue_free()

	for hab in habilities:
		_add_row(hab, available_habilities.get(hab, 0)==0)


func _on_hability_info_requested(hab: HabilityRes) -> void:
	var root = get_tree().root
	var existing = root.get_node_or_null("HabilityPanel")
	
	# Si está abierto cerrarlo y salir
	if existing:
		existing.queue_free()
		return
	
	var hability_scene = preload("res://scenes/hability.tscn").instantiate()
	hability_scene.name = "HabilityPanel"
	root.add_child(hability_scene)
	hability_scene.paint(hab)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var anchor_global = habilities_grid.global_position
	var anchor_size = habilities_grid.size
	var scene_size = hability_scene.size
	var vp_size = get_viewport_rect().size
	
	# Posición base: a la derecha del grid de habilidades
	var pos = Vector2(anchor_global.x + anchor_size.x + 5, anchor_global.y)
	
	# Ajustar si se sale por la derecha
	if pos.x + scene_size.x > vp_size.x:
		pos.x = anchor_global.x - scene_size.x - 5
	
	# Ajustar si se sale por abajo
	if pos.y + scene_size.y > vp_size.y:
		pos.y = vp_size.y - scene_size.y
	
	hability_scene.global_position = pos
func _create_cell(text: String, color: Color, is_header: bool = false) -> PanelContainer:
	var panel = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3) if is_header else Color(0.1, 0.1, 0.15)
	style.border_width_bottom = 1
	style.border_width_right = 1
	style.border_color = Color(0.4, 0.4, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_bottom", 2)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	
	margin.add_child(label)
	panel.add_child(margin)
	return panel




func _add_row(hab: HabilityRes, available: bool) -> void:
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)

	var btn_use = Button.new()
	btn_use.text = hab.name
	btn_use.disabled = not available
	btn_use.custom_minimum_size = Vector2(120, 0)
	btn_use.pressed.connect(func(): emit_signal("hability_use_requested", hab))
	row.add_child(btn_use)

	var btn_info = Button.new()
	btn_info.text = "i"
	btn_info.custom_minimum_size = Vector2(30, 0)
	btn_info.pressed.connect(func(): _on_hability_info_requested(hab))
	row.add_child(btn_info)

	habilities_grid.columns = 1
	habilities_grid.add_theme_constant_override("v_separation", 6)
	habilities_grid.add_child(row)


func _get_effect_text(state: AlterStateRes) -> String:
	if state.stat == null:
		return "-"
	
	var sign = "+" if state.value >= 0 else ""
	var value_text: String
	
	if state.stat.isPercent:
		value_text = "%s%.0f%%" % [sign, state.value * 100]
	else:
		value_text = "%s%.0f" % [sign, state.value]
	
	var prob_text = ""
	if state.hitP < 1.0:
		prob_text = " (%.0f%%)" % (state.hitP * 100)
	
	return value_text + prob_text

func _get_stat_icon(stat_name: StringName) -> String:
	match stat_name:
		StatData.DEFENSE:   return "🛡"
		StatData.SPEED:     return "⚡"
		StatData.HEALTH:    return "❤"
		StatData.ATTACK:    return "⚔"
		StatData.MANA:      return "💧"
		_:                  return "◆"

func paint_AlterStates(states: Dictionary[AlterStateRes, int]) -> void:
	if states == null:
		return
	for child in alter_states_grid.get_children():
		child.queue_free()
	
	if states.is_empty():
		alter_states_grid.add_child(_create_cell("Sin estados activos", Color.GRAY))
		return
	
	alter_states_grid.columns = 3
	
	# Headers
	for header in ["Efecto", "Valor", "Turnos"]:
		alter_states_grid.add_child(_create_cell(header, Color.YELLOW, true))
	
	for state in states.keys():
		var turns_remaining: int = states[state]
		var icon = _get_stat_icon(state.stat.name if state.stat else &"")
		
		alter_states_grid.add_child(_create_cell(
			"%s %s" % [icon, state.stat.name if state.stat else "?"],
			Color.WHITE if state.value >= 0 else Color.TOMATO
		))
		alter_states_grid.add_child(_create_cell(
			_get_effect_text(state),
			Color.LIGHT_GREEN if state.value >= 0 else Color.TOMATO
		))
		alter_states_grid.add_child(_create_cell(
			"%dt" % turns_remaining,
			Color.YELLOW if turns_remaining <= 1 else Color.WHITE
		))


#
#func observe(unit: UnitGame) -> void:
	#if _observed_unit != null:
		#if _observed_unit.mana_changed.is_connected(_on_mana_changed):
			#_observed_unit.mana_changed.disconnect(_on_mana_changed)
#
	#_observed_unit = unit
	#current_mana.init(unit._cardRes.mana)
	#current_mana.update(unit.mana)
#
	#unit.mana_changed.connect(_on_mana_changed)
	#


func _on_mana_changed(current: int) -> void:

	current_mana.update(current)
