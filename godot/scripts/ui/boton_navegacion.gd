@tool
class_name BotonNavegacion
extends Button

var id_escena: String = ""

func _get_property_list() -> Array:
	var propiedades: Array = []
	var opciones: String = ",".join(EscenasConfig.MAPA_ESCENAS.keys())
	
	propiedades.append({
		"name": "id_escena",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": opciones
	})
	
	return propiedades

func _ready() -> void:
	if not Engine.is_editor_hint():
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if id_escena != "":
		UiManager.cambiar_a_escena(id_escena)
