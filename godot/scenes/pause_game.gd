extends Control

const EXIT_GAME_SCENE = preload("res://scenes/exit_game.tscn")

@export var reanudar: Button
@export var salir: Button
@export var menuPrincipal: Button

func _ready() -> void:
	reanudar.pressed.connect(_on_reanudar)
	salir.pressed.connect(_on_salir)
	menuPrincipal.pressed.connect(_on_menuPrincipal)

func _on_reanudar() -> void:
	visible = false
	#mas cosas

func _on_salir() -> void:
	var exit_dialog = EXIT_GAME_SCENE.instantiate()
	get_tree().root.add_child(exit_dialog)
	exit_dialog.confirmed.connect(func(): UiManager.cambiar_a_escena("inicio"))
	exit_dialog.cancelled.connect(func(): exit_dialog.queue_free())

func _on_menuPrincipal() -> void:
	UiManager.cambiar_a_escena("inicio")
