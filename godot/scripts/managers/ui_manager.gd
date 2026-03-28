extends Node

func cambiar_a_escena(id: String) -> void:
	if EscenasConfig.MAPA_ESCENAS.has(id):
		var ruta: String = EscenasConfig.MAPA_ESCENAS[id]
		if ResourceLoader.exists(ruta):
			get_tree().change_scene_to_file(ruta)
		else:
			push_error("UIManager: La ruta no existe: " + ruta)
	else:
		push_error("UIManager: La ID '" + id + "' no está definida en EscenasConfig.")
