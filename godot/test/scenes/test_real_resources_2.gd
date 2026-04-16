class_name TestRealResources
extends GutTest

const MAP_SCENE_PATH: String = "res://scenes/ingame/game_scene.tscn"

func test_sandbox_interactivo_movimiento() -> void:
	# 1. PREPARACIÓN DEL ESCENARIO
	var gr = GameResources.load_from()
	var user_a = gr.users[0]
	var user_b = gr.users[1]
	
	GameManager._gameMap = gr.maps[0]
	
	var map_instance = load(MAP_SCENE_PATH).instantiate()
	add_child_autoqfree(map_instance)
	
	# Godot 4: Esperamos 2 frames lógicos para que los nodos hagan su _ready()
	await wait_frames(2)
	
	var turn_manager = map_instance
	var visualizer = _find_visualizer_node(map_instance)
	
	# 2. CONFIGURAR TURNOS (Forma segura para evitar errores de Array tipado)
	turn_manager.turn_order.clear()
	turn_manager.turn_order.append(user_a)
	turn_manager.turn_order.append(user_b)
	turn_manager.turn_number = 0 # Le toca a user_a
	
	# 3. COLOCACIÓN DE UNIDADES
	# --- Unidad Aliada (Usuario A) ---
	var ally_unit = UnitGame.new(gr.cards[0])
	ally_unit._owner = user_a
	var ally_pos = Vector2i(0, 0) # Asegúrate de que esta casilla es "pisable"
	var tile_ally = visualizer.map.get_tile_at(ally_pos)
	tile_ally.set_unit(ally_unit)
	ally_unit._tile = tile_ally
	
	# --- Unidad Enemiga (Usuario B) ---
	var enemy_unit = UnitGame.new(gr.cards[1])
	enemy_unit._owner = user_b
	var enemy_pos = Vector2i(0, 1) # Cambiado a (2,2) para evitar salirnos del mapa
	var tile_enemy = visualizer.map.get_tile_at(enemy_pos)
	tile_enemy.set_unit(enemy_unit)
	enemy_unit._tile = tile_enemy
	
	# Forzamos el dibujado inicial de la interfaz
	visualizer._setup_map()

	print("\n=======================================================")
	print("ESCENARIO INTERACTIVO CARGADO:")
	print("- Unidad aliada en (1, 1)")
	print("- Unidad enemiga en (2, 2)")
	print("=> Usa el ratón para probar seleccionar y mover.")
	print("=======================================================\n")

	# 4. CEDER EL CONTROL AL USUARIO
	# Esto pausa la ejecución del código del test, pero mantiene el juego vivo 
	# para que puedas interactuar con la pantalla usando tu ratón.
	gut.pause_before_teardown()

# Helper para encontrar el visualizador navegando el árbol
func _find_visualizer_node(node: Node) -> mapVisualizer:
	if node is mapVisualizer: 
		return node
	for child in node.get_children():
		var found = _find_visualizer_node(child)
		if found: 
			return found
	return null
