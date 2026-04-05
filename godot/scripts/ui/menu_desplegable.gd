extends Button


enum Lado { DERECHA, IZQUIERDA, ARRIBA, ABAJO }

@export var posicion_menu: Lado = Lado.DERECHA 
@export var separacion: float = 5.0           

var menu_interno: Panel = null

func _ready():
	for hijo in get_children():
		if hijo is Panel:
			menu_interno = hijo
			break
	
	if menu_interno:
		menu_interno.visible = false
		
		menu_interno.resized.connect(actualizar_posicion)
		actualizar_posicion()
		
		pressed.connect(_on_self_pressed)
		add_to_group("botones_desplegables")

func _on_self_pressed():
	if menu_interno:
		if not menu_interno.visible:
			get_tree().call_group("botones_desplegables", "cerrar_menu")
		
		actualizar_posicion()
		menu_interno.visible = !menu_interno.visible

# Esta es la lógica que mueve el menú según tu elección
func actualizar_posicion():
	if not menu_interno: return
	
	match posicion_menu:
		Lado.DERECHA:
			menu_interno.position = Vector2(size.x + separacion, 0)
		Lado.IZQUIERDA:
			menu_interno.position = Vector2(-menu_interno.size.x - separacion, 0)
		Lado.ARRIBA:
			menu_interno.position = Vector2(0, -menu_interno.size.y - separacion)
		Lado.ABAJO:
			menu_interno.position = Vector2(0, size.y + separacion)

func cerrar_menu():
	if menu_interno:
		menu_interno.visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if menu_interno and menu_interno.visible:
			var click_en_boton = get_global_rect().has_point(event.global_position)
			var click_en_menu = menu_interno.get_global_rect().has_point(event.global_position)
			
			if not click_en_boton and not click_en_menu:
				menu_interno.visible = false
