extends Node


const TRANSITION_SCENE = preload("res://scenes/transition_screen.tscn")



@export var icono_jugador_1: Texture2D
@export var icono_jugador_2: Texture2D

var transition_screen: CanvasLayer

func _ready() -> void:
	transition_screen = TRANSITION_SCENE.instantiate()
	add_child(transition_screen)
	_play_showcase()

func _play_showcase() -> void:
	
	await get_tree().create_timer(1.0).timeout
	

	while true:
	
		transition_screen.play_deployment_transition("Tenma")
		await get_tree().create_timer(4.0).timeout 
		
	
		transition_screen.play_combat_transition("Atenea")
		await get_tree().create_timer(4.0).timeout
		
		
		transition_screen.play_turn_transition(icono_jugador_1, "Tenma", icono_jugador_2)
		await get_tree().create_timer(4.0).timeout
		
		
		
		transition_screen.play_turn_transition_fast(icono_jugador_2, "Atenea", icono_jugador_1)
		
		await get_tree().create_timer(3.0).timeout 
		
		
