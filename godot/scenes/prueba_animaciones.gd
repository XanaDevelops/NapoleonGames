extends Node

# ⚠️ Asegúrate de que esta ruta apunte a tu escena de transición
const TRANSITION_SCENE = preload("res://scenes/transition_screen.tscn")



@export var icono_jugador_1: Texture2D
@export var icono_jugador_2: Texture2D

var transition_screen: CanvasLayer

func _ready() -> void:
	transition_screen = TRANSITION_SCENE.instantiate()
	add_child(transition_screen)
	_play_showcase()

func _play_showcase() -> void:
	# Un pequeño respiro antes de empezar
	await get_tree().create_timer(1.0).timeout
	
	# Bucle infinito con las 4 animaciones
	while true:
		print("🎬 Acción 1: Despliegue (Abanico de Cartas)")
		transition_screen.play_deployment_transition("Tenma")
		await get_tree().create_timer(4.0).timeout 
		
		print("🎬 Acción 2: Combate (Choque de Espadas)")
		transition_screen.play_combat_transition("Atenea")
		await get_tree().create_timer(4.0).timeout
		
		print("🎬 Acción 3: Turno NORMAL (3 Giros)")
		transition_screen.play_turn_transition(icono_jugador_1, "Tenma", icono_jugador_2)
		await get_tree().create_timer(4.0).timeout
		
		print("🎬 Acción 4: Turno RÁPIDO (1 Giro)")
		
		transition_screen.play_turn_transition_fast(icono_jugador_2, "Atenea", icono_jugador_1)
		
		await get_tree().create_timer(3.0).timeout 
		
		print("🔄 Reiniciando el bucle...")
