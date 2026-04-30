extends Control


@onready var unit_label: Label = $VBoxContainer/VBoxContainer/UnitLabel
@onready var unit_texture: TextureRect = $VBoxContainer/VBoxContainer/UnitTextureRect
@onready var description_label: Label = $VBoxContainer/PanelContainer/HBoxContainer/DescriptionLabel
@onready var description_text: Label = $VBoxContainer/PanelContainer/HBoxContainer/ScrollContainer/DescriptionText
@onready var owner_label: Label = $VBoxContainer/VBoxContainer2/OwnerLabel
@onready  var speed_label: Label = $VBoxContainer/VBoxContainer2/SpeedLabel
@onready var dodge_label: Label = $VBoxContainer/VBoxContainer2/DodgeLabel
@onready var weight_label : Label = $VBoxContainer/VBoxContainer2/WeightLabel
@onready var resistances_container: PanelContainer = $VBoxContainer/ResistancesContainer
@onready var habilities_container: PanelContainer = $VBoxContainer/HabilitiesContainer
@onready var currrentAlterStates_container: PanelContainer = $VBoxContainer/CurrenAlterStatesContainer
@onready var habilities_grid: GridContainer= $VBoxContainer/HabilitiesContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var grid_scroll: ScrollContainer = $VBoxContainer/HabilitiesContainer/VBoxContainer/ScrollContainer
@onready var resistances_grid : GridContainer= $VBoxContainer/ResistancesContainer/VBoxContainer/ResistancesScrollContainer/ResistancesGridContainer
@onready var alter_states_grid: GridContainer = $VBoxContainer/CurrenAlterStatesContainer/VBoxContainer/ScrollContainer/AlterStatesGridContainer
@onready var current_health: ProgressBar = $VBoxContainer/Bars/HealthBar
@onready var current_mana: ProgressBar = $VBoxContainer/Bars/ManaBar

const HEADERS_RESISTANCES= ["Tipo de ataque", "Resistencia"]
const ALTER_HEADERS = ["Estado", "Turnos Faltantes", "Efecto"]
signal hability_use_requested(hab: HabilityRes)
# UnitInfo
var _observed_unit: UnitGame = null
func _ready() -> void:
	await get_tree().process_frame
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	

func paint(tile: TileGame) -> void:
	self.unit_label.text =tile.get_tile_name() 
	self.description_text.text= tile.get_tile_desc()
	self.owner_label.text = "Owner: %s" %tile.get_owner_name()
	self.weight_label.text=  "Altura: %d" % tile.get_unit_weight()
	self.unit_texture.texture= tile.get_unit_portrait()
	self.speed_label.text = "Speed : %d" % tile.get_speed()
	self.dodge_label.text = "Dodge : %d" % tile.get_dodge()
	self.current_health.init(tile.get_currentHealth())
	self.current_mana.init(tile.get_currentMana())

	paint_resistances(tile.get_resistances())
	paint_habilities(tile.get_habilities(),tile.get_availableHabilities())
	paint_AlterStates(tile.get_AlterStates())

func paint_habilities(habilities: Array[HabilityRes], available_habilities: Dictionary[HabilityRes, int]) -> void:
	if habilities== null:
		return
	for child in habilities_grid.get_children():
		child.queue_free()

	for hab in habilities:
		_add_row(hab, available_habilities.get(hab, 0)==0)

func _on_hability_info_requested(hab: HabilityRes) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = str(hab.name)
	dialog.dialog_text = """
		Descripción: %s
		Objetivo: %s
		Maná: %d
		Rango: %d
		Cooldown: %dt
		Pasiva: %s
	""" % [
		hab.desc,
		_objective_text(hab.objective),
		hab.manaCost,
		hab.radius,
		hab.cooldown,
		"Sí" if hab.isPassive else "No"
	]
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())


func _objective_text(obj: HabilityRes.HAB_DEST) -> String:
	match obj:
		HabilityRes.HAB_DEST.SINGLE_ENEMY:  return "Enemigo"
		HabilityRes.HAB_DEST.MULTI_ENEMY:   return "Enemigos"
		HabilityRes.HAB_DEST.SINGLE_ALLY:   return "Aliado"
		HabilityRes.HAB_DEST.MULTIPLE_ALLY: return "Aliados"
		HabilityRes.HAB_DEST.SELF:          return "Uno mismo"
		HabilityRes.HAB_DEST.EVERYONE:      return "Todos"
		_: return "-"
 
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
	
	var name_label = Label.new()
	name_label.text = str(hab.name)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override("font_color", Color.WHITE if available else Color.GRAY)
	row.add_child(name_label)
	
	var btn_info = Button.new()
	btn_info.text = "i"

	btn_info.pressed.connect(func(): _show_hability_info(hab))
	row.add_child(btn_info)
	
	var btn_use = Button.new()
	btn_use.text = "Usar"
	btn_use.disabled = not available
	btn_use.pressed.connect(func(): emit_signal("hability_use_requested", hab, ))
	row.add_child(btn_use)
	
	habilities_grid.columns = 1
	habilities_grid.add_child(row)

func _show_hability_info(hab: HabilityRes) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = str(hab.name)
	dialog.dialog_text = "Descripción: %s\nObjetivo: %s\nManá: %d\nRango: %d\nCD: %dt\nPasiva: %s" % [
		hab.desc,
		_objective_text(hab.objective),
		hab.manaCost,
		hab.radius,
		hab.cooldown,
		"Sí" if hab.isPassive else "No"
	]
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())

  

func _add_row_resistance(attack: AttackType, resistance: int) -> void:
	var values = [
		str(attack.name),
		str(resistance)
	]
	for val in values: 
		resistances_grid.add_child(_create_cell(val, Color.ANTIQUE_WHITE))
		
func paint_resistances(resistances: Dictionary[AttackType, int]) -> void:
	if resistances== null:
		return
	for child in resistances_grid.get_children():
		child.queue_free()
	
	resistances_grid.columns = HEADERS_RESISTANCES.size()
	
	for header in HEADERS_RESISTANCES:
		resistances_grid.add_child(_create_cell(header, Color.YELLOW, true))
	
	for key in resistances.keys():
		_add_row_resistance(key, resistances[key] )



func paint_AlterStates(states: Dictionary[AlterStateRes, int]) -> void:
	if states==null:
		return 
	for child in alter_states_grid.get_children():
		child.queue_free()
	

	alter_states_grid.columns = ALTER_HEADERS.size()
	

	for header in ALTER_HEADERS:
		alter_states_grid.add_child(_create_cell(header, Color.YELLOW, true))
	
	for state in states.keys():
		var turns_remaining: int = states[state]
		alter_states_grid.add_child(_create_cell(state.stat.name, Color.WHITE))
		alter_states_grid.add_child(_create_cell("%d" % turns_remaining, Color.WHITE))
		alter_states_grid.add_child(_create_cell(_get_effect_text(state), Color.WHITE))


func _get_effect_text(state: AlterStateRes) -> String:
	if state.stat == null:
		return "-"
	
	var sign = "+" if state.value >= 0 else ""
	var value_text: String
	
	if state.stat.isPercent:
		value_text = "%s%.0f%%" % [sign, state.value * 100]
	else:
		value_text = "%s%.0f " % [sign, state.value]
	
	if state.hitP < 1.0:
		return "%s (%.0f%%)" % [value_text, state.hitP * 100]
	else:
		return value_text



func observe(unit: UnitGame) -> void:
	if _observed_unit != null:
		_observed_unit.health_changed.disconnect(_on_health_changed)
		_observed_unit.mana_changed.disconnect(_on_mana_changed)

	_observed_unit = unit
	current_health.init(unit.hp)
	current_mana.init(unit.mana)
	current_health.update(unit.hp)
	current_mana.update(unit.mana)

	unit.health_changed.connect(_on_health_changed)
	unit.mana_changed.connect(_on_mana_changed)

func _on_health_changed(current: int) -> void:
	current_health.update(current)

func _on_mana_changed(current: int) -> void:
	current_mana.update(current)
