extends Button


enum Lado { DERECHA, IZQUIERDA, ARRIBA, ABAJO }

@export var posicion_menu: Lado = Lado.DERECHA 
@export var separacion: float = 5.0           

var menu_interno: Panel = null
@onready var icoono_usuario: TextureRect= %IconoUsuario

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
		
	UserManager.usuario_cambiado.connect(_actualizar_imagen)
	
	
	if UserManager.usuario_actual != null:
		_actualizar_imagen(UserManager.usuario_actual.name,UserManager.usuario_actual.img)




func _actualizar_imagen(texto: String,foto: Texture2D) -> void:
	icoono_usuario.texture=foto

func _on_self_pressed():
	if menu_interno:
		if not menu_interno.visible:
			get_tree().call_group("botones_desplegables", "cerrar_menu")
		
		actualizar_posicion()
		menu_interno.visible = !menu_interno.visible


func actualizar_posicion():
	if not menu_interno: return
	
	
	var centro_x = (size.x - menu_interno.size.x) / 2.0
	var centro_y = (size.y - menu_interno.size.y) / 2.0
	
	match posicion_menu:
		Lado.DERECHA:
			menu_interno.position = Vector2(size.x + separacion, centro_y)
		Lado.IZQUIERDA:
			menu_interno.position = Vector2(-menu_interno.size.x - separacion, centro_y)
		Lado.ARRIBA:
			menu_interno.position = Vector2(centro_x, -menu_interno.size.y - separacion)
		Lado.ABAJO:
			menu_interno.position = Vector2(centro_x, size.y + separacion)

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
				
