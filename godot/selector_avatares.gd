extends Panel

signal avatar_seleccionado(textura: Texture2D)

@export var tema_normal: Theme
@export var tema_seleccionado: Theme

@export_global_dir var ruta_carpeta_avatares: String = "res://"

var avatares_disponibles: Array[Texture2D] = []
@onready var grid_avatares = %GridAvatares

var boton_activo: Button = null

func _ready() -> void:
	cargar_avatares_desde_carpeta()
	generar_selector()

func cargar_avatares_desde_carpeta() -> void:
	avatares_disponibles.clear()
	
	var dir = DirAccess.open(ruta_carpeta_avatares)
	if dir:
		dir.list_dir_begin()
		var nombre_archivo = dir.get_next()
		
		while nombre_archivo != "":
			if not dir.current_is_dir():
				var ruta_completa = ruta_carpeta_avatares + "/" + nombre_archivo
				
				if nombre_archivo.ends_with(".png") or nombre_archivo.ends_with(".jpg") or nombre_archivo.ends_with(".jpeg"):
					var textura = load(ruta_completa) as Texture2D
					if textura and not avatares_disponibles.has(textura):
						avatares_disponibles.append(textura)
						
				elif nombre_archivo.ends_with(".import"):
					var nombre_original = nombre_archivo.replace(".import", "")
					if nombre_original.ends_with(".png") or nombre_original.ends_with(".jpg") or nombre_original.ends_with(".jpeg"):
						var ruta_original = ruta_carpeta_avatares + "/" + nombre_original
						
						if ResourceLoader.exists(ruta_original):
							var textura = load(ruta_original) as Texture2D
							if textura and not avatares_disponibles.has(textura):
								avatares_disponibles.append(textura)
								
			nombre_archivo = dir.get_next()
	else:
		push_error("Error: No se pudo abrir la carpeta de avatares en la ruta: " + ruta_carpeta_avatares)

func generar_selector() -> void:
	for hijo in grid_avatares.get_children():
		hijo.queue_free()
		
	for textura in avatares_disponibles:
		var boton = Button.new()
		boton.custom_minimum_size = Vector2(150, 150)
		
		# Es buena idea asignarle el tema normal por defecto al crearlo
		boton.theme = tema_normal 
		
		var tex_rect = TextureRect.new()
		tex_rect.texture = textura
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		
		boton.add_child(tex_rect)
		tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		
		
		
		
		boton.gui_input.connect(func(event): _on_avatar_gui_input(event, boton, textura))
		
		grid_avatares.add_child(boton)
		
func _on_avatar_gui_input(event: InputEvent, boton_clicado: Button, textura: Texture2D) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			avatar_seleccionado.emit(textura)
		else:
			if boton_activo != null and is_instance_valid(boton_activo):
				boton_activo.theme = tema_normal
				
			boton_activo = boton_clicado
			boton_activo.theme = tema_seleccionado
