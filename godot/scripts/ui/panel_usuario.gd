extends Panel

const FILA_USUARIO_ESCENA = preload("res://scenes/fila_usuario_menu.tscn")

@onready var contenedor_usuarios = $Panel/ScrollContainer/ContenedorUsuarios

func _ready():
	cargar_lista_de_usuarios()

func cargar_lista_de_usuarios() -> void:
	for hijo in contenedor_usuarios.get_children():
		hijo.queue_free()
		
	var usuarios_registrados = UserManager.usuarios
	
	for email in usuarios_registrados:
		var usuario: UserRes = usuarios_registrados[email]
		var nueva_fila = FILA_USUARIO_ESCENA.instantiate()
		
		contenedor_usuarios.add_child(nueva_fila)
		nueva_fila.inicializar(usuario)
