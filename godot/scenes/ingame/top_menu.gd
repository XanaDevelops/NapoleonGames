extends PanelContainer

@export var TimeLabel: Label
@export var TurnLabel: Label
@export var OptionsButton: Button
@export var PhaseLabel: Label

var _elapsed_time: float = 0.0
var _options_panel: Control = null

func _ready() -> void:
	#OptionsButton.pressed.connect(_on_options_button_pressed)
	pass

func _process(delta: float) -> void:
	_elapsed_time += delta
	var minuts = int(_elapsed_time) / 60
	var seconds = int(_elapsed_time) % 60
	TimeLabel.text = "%02d:%02d" % [minuts, seconds]

func _on_options_button_pressed() -> void:
	# Si ya está abierto, cerrarlo
	if is_instance_valid(_options_panel):
		_options_panel.queue_free()
		_options_panel = null
		return
	
	_options_panel = preload("res://test/scenes/options_ingame.tscn").instantiate()
	get_tree().root.add_child(_options_panel)
	
	await get_tree().process_frame
	
	# Posicionar debajo del botón
	var btn_global = OptionsButton.global_position
	var btn_size = OptionsButton.size
	var vp_size = get_viewport_rect().size
	
	var pos = Vector2(btn_global.x, btn_global.y + btn_size.y)
	
	# Ajustar si se sale por la derecha
	if pos.x + _options_panel.size.x > vp_size.x:
		pos.x = vp_size.x - _options_panel.size.x
	
	_options_panel.global_position = pos

func _input(event: InputEvent) -> void:
	if not is_instance_valid(_options_panel):
		return
	if event is InputEventMouseButton and event.pressed:
		if not _options_panel.get_global_rect().has_point(event.global_position) \
		and not OptionsButton.get_global_rect().has_point(event.global_position):
			_options_panel.queue_free()
			_options_panel = null
