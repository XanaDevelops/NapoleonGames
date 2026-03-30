extends Control

func _ready() -> void:
	# Buscamos todos los botones de navegación en la escena y los conectamos al Manager
	for boton in get_tree().get_nodes_in_group("botones_navegacion"):
		if boton is BotonNavegacion:
			boton.cambio_escena_solicitado.connect(UiManager.cambiar_a_escena)
