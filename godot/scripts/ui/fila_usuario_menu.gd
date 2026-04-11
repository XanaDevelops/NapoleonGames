extends Button

@onready var label_nombre = $HBoxContainer/Label
@onready var contenedor_botones_online = $HBoxContainer2
@onready var boton_editar = $HBoxContainer2/EditarPerfil
@onready var boton_cerrar = $HBoxContainer2/QuitarCuenta

var color_seleccionado = Color(0.6, 1.0, 0.6)
var color_normal = Color(1.0, 1.0, 1.0)

var email_usuario: String

func _ready():
	pressed.connect(_on_fila_presionada)
	UserManager.usuario_cambiado.connect(_on_usuario_cambiado_globalmente)

func inicializar(usuario: UserRes) -> void:
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

func _on_usuario_cambiado_globalmente(email_nuevo_activo: String) -> void:
	resaltar_fila(email_nuevo_activo == email_usuario)

func resaltar_fila(es_seleccionado: bool) -> void:
	if es_seleccionado:
		modulate = color_seleccionado
	else:
		modulate = color_normal
