extends Button


@export var escena_panel_salida: PackedScene

func _ready() -> void:

	pressed.connect(_on_pressed)

func _on_pressed() -> void:

	if escena_panel_salida != null:
		
		var exit_panel = escena_panel_salida.instantiate()
		
		
		get_tree().current_scene.add_child(exit_panel)
	else:
		push_error("No has asignado la escena 'exit_game.tscn' en el Inspector del botón.")
