extends Button

@onready var label_nombre = $%NombreUsuario
@onready var contenedor_botones_online = %ContenedorDeBotones
@onready var boton_editar = %EditarPerfil
@onready var boton_cerrar = %QuitarCuenta
@onready var icono =%Icono
@export var tema_seleccionado: Theme
@export var tema_normal: Theme


var email_usuario: String

func _ready():
	pressed.connect(_on_fila_presionada)
	UserManager.usuario_cambiado.connect(_on_usuario_cambiado_globalmente)
	boton_editar.pressed.connect(_on_boton_editar_presionado)

func inicializar(usuario: UserRes) -> void:
	icono.texture=usuario.img
	email_usuario = usuario.email
	label_nombre.text = usuario.name
	
	if UserManager.es_usuario_local(usuario.email):
		contenedor_botones_online.hide()
	else:
		contenedor_botones_online.show()
		
	if UserManager.usuario_actual != null and UserManager.usuario_actual.email == email_usuario:
		resaltar_fila(true)
	else:
		resaltar_fila(false)

func _on_fila_presionada() -> void:
	UserManager.establecer_usuario_actual(email_usuario)

func _on_usuario_cambiado_globalmente(email_nuevo_activo: String,foto_usuario: Texture2D) -> void:
	resaltar_fila(email_nuevo_activo == email_usuario)

func resaltar_fila(es_seleccionado: bool) -> void:
	
	if es_seleccionado:
		theme = tema_seleccionado
	else:
		theme = tema_normal

func _on_boton_editar_presionado() -> void:
	
		var usuario_seleccionado = UserManager.usuarios[email_usuario]
		UiManager.cambiar_a_escena("perfil", {
			"usuario_a_editar": usuario_seleccionado
		})
