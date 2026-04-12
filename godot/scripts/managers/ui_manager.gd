extends Node

func cambiar_a_escena(identificador: String, parametros: Dictionary = {}) -> void:
	if EscenasConfig.MAPA_ESCENAS.has(identificador):
		var ruta_escena: String = EscenasConfig.MAPA_ESCENAS[identificador]
		
		if ResourceLoader.exists(ruta_escena):
			var recurso_escena = load(ruta_escena)
			var nueva_escena = recurso_escena.instantiate()
			
			for clave in parametros:
				nueva_escena.set(clave, parametros[clave])
			
			var arbol_principal = get_tree()
			var escena_actual = arbol_principal.current_scene
			
			arbol_principal.root.add_child(nueva_escena)
			arbol_principal.current_scene = nueva_escena
			
			if escena_actual:
				escena_actual.queue_free()
		else:
			push_error("UIManager: La ruta no existe: " + ruta_escena)
	else:
		push_error("UIManager: El identificador '" + identificador + "' no está definido en EscenasConfig.")
