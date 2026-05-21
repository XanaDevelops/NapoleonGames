extends Control


@onready var username_input: LineEdit = $Panel/VBoxContainer/VBoxContainer/LineEdit
@onready var email_input: LineEdit = $Panel/VBoxContainer/VBoxContainer5/LineEdit
@onready var email_confirm_input: LineEdit = $Panel/VBoxContainer/VBoxContainer2/LineEdit
@onready var password_input: LineEdit = $Panel/VBoxContainer/VBoxContainer3/LineEdit
@onready var password_confirm_input: LineEdit = $Panel/VBoxContainer/VBoxContainer4/LineEdit
@onready var signin_button: Button = $Panel/Button


@onready var foto_perfil: TextureRect = %IconoUsuario
@onready var boton_cambiar_foto: Button = %BotonCambiarFoto 
@onready var selector_avatares = %SelectorAvatares


var ruta_imagen_elegida: String = ""

func _ready() -> void:
	print("REGISTRO READY")
	
	
	signin_button.pressed.connect(_on_signin_pressed)
	
	
	selector_avatares.hide()
	boton_cambiar_foto.pressed.connect(func(): selector_avatares.show())
	selector_avatares.avatar_seleccionado.connect(_on_avatar_seleccionado)

func _on_avatar_seleccionado(textura_elegida: Texture2D) -> void:
	foto_perfil.texture = textura_elegida
	selector_avatares.hide()
	
	
	ruta_imagen_elegida = textura_elegida.resource_path 

func _on_signin_pressed() -> void:
	print("BOTON REGISTRO")

	var username := username_input.text.strip_edges()
	var email := email_input.text.strip_edges()
	var email_confirm := email_confirm_input.text.strip_edges()
	var password := password_input.text
	var password_confirm := password_confirm_input.text

	if username.is_empty() or email.is_empty() or password.is_empty():
		push_warning("Username, email y password son obligatorios")
		return

	if email != email_confirm:
		push_warning("Los correos no coinciden")
		return

	if password != password_confirm:
		push_warning("Las contraseñas no coinciden")
		return


	ApiAdapter.signin(
		username,
		email,
		password,
		username,
		ruta_imagen_elegida 
	)
