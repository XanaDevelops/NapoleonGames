extends Panel

@export var pause: Button
@export var exit: Button
@export var settings: Button

func _ready() -> void:
	pause.pressed.connect(_on_pause_pressed)
	exit.pressed.connect(_on_exit_pressed)
	settings.pressed.connect(_on_settings_pressed)

func _show_centered(scene_path: String) -> void:
	var existing = get_tree().root.get_node_or_null(scene_path.get_file().get_basename())
	if existing:
		existing.queue_free()
	
	var scene = load(scene_path).instantiate()
	get_tree().root.add_child(scene)
	
	await get_tree().process_frame
	scene.global_position = (get_viewport_rect().size - scene.size) / 2.0

func _on_pause_pressed() -> void:
	_show_centered("res://scenes/pause_game.tscn")

func _on_exit_pressed() -> void:
	_show_centered("res://scenes/exit_game.tscn")

func _on_settings_pressed() -> void:
	pass
