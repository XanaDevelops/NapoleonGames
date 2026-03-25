extends MenuButton

class_name SideMenuButton

func _ready():
	
	var popup = get_popup()
	popup.about_to_popup.connect(_on_about_to_popup)

func _on_about_to_popup():
	var popup = get_popup()
	var nueva_posicion = Vector2i(global_position.x + size.x, global_position.y)
	
	popup.set_position(nueva_posicion)
