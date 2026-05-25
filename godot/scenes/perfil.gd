extends Control

@onready var input_nombre = %NombreInput
@onready var input_email = %EmailInput
@onready var foto_perfil = %FotoPerfil

var usuario_a_editar: UserRes = null

func _ready() -> void:
	
	if usuario_a_editar != null:
		cargar_datos_en_interfaz(usuario_a_editar)
		print("Modo edición activado para: ", usuario_a_editar.name)
	else:
		print("Modo creación de nuevo usuario")

func cargar_datos_en_interfaz(usuario: UserRes) -> void:
	input_nombre.text = usuario.name
	input_email.text = usuario.email
	foto_perfil.texture = usuario.img
