class_name CircularEndTurn
extends Control

@export var label: Label 
@export var boton:Button

func _ready() -> void:
	visible = false
	boton.pressed.connect(_end_turn)

func show_battle() -> void:
	visible = true


func _end_turn() -> void:
	GameManager.get_turn_manager().advance_turn()
