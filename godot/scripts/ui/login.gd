extends Control

@onready var username_input: LineEdit = $Panel/VBoxContainer/VBoxContainer5/LineEdit
@onready var password_input: LineEdit = $Panel/VBoxContainer/VBoxContainer3/LineEdit
@onready var login_button: Button = $Panel/Button

func _ready() -> void:
	print("LOGIN READY")
	login_button.pressed.connect(_on_login_pressed)
	
func _on_login_pressed() -> void:
	print("BOTON LOGIN")
	var username := username_input.text.strip_edges()
	var password := password_input.text

	if username.is_empty() or password.is_empty():
		push_warning("Username y password son obligatorios")
		return

	ApiAdapter.login(username, password)
