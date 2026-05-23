class_name GameScene
extends Control

@export var map_container: SubViewportContainer 

@export var cards_panel:   Control              
@export var sub_viewport:  SubViewport          
@export var map_visualizer: mapVisualizer      
@export var unit_info:     PanelContainer              
@export var deployment_box: HBoxContainer       

@onready var turn_manager: TurnManager = get_parent() as TurnManager

@export var transition_screen_scene: PackedScene
var transition_screen: Node

var _pending_deployment_group: CardArmyGroup = null

var ganador_actual: String = ""

enum UnitState {
	IDLE,
	UNIT_SELECTED,
	HABILITY_ACTIVE, 
}

var map:              MapGame       = null
var _hab_manager:     HabilityManager
var _state:           UnitState    = UnitState.IDLE
var _selected_tile:   TileGame     = null
var _selected_coords: Vector2i     = Vector2i(-1, -1)

func _ready() -> void:
	
	if turn_manager == null:
		turn_manager = get_parent() as TurnManager
		if turn_manager == null:
			turn_manager = GameManager.get_turn_manager()
			
	
	if transition_screen_scene != null:
		transition_screen = transition_screen_scene.instantiate()
		add_child(transition_screen)
		
		turn_manager.deployment_phase_started.connect(transition_screen.play_deployment_transition)
		turn_manager.combat_phase_started.connect(transition_screen.play_combat_transition)
		turn_manager.turn_changed_visual.connect(transition_screen.play_turn_transition_fast)
		turn_manager.inicializar_finalizacion.connect(_on_juego_terminado)
		transition_screen.end_game_transition_finished.connect(_on_transicion_terminada)
	else:
		push_warning("GameScene: No se ha asignado la escena de transición en el inspector.")


	await get_tree().process_frame
	
	map = turn_manager.get_map()
	if map == null:
		push_error("GameScene: no tiene mapa — usando mapa de test")
		map = TestMapGame.new().create_test_map()
		if turn_manager:
			turn_manager.set_map(map)
	map_visualizer._setup_map(map)
	await get_tree().process_frame
	await get_tree().process_frame
	map_visualizer.center_camera(Vector2(sub_viewport.size))
	
	_hab_manager = HabilityManager.new()
	add_child(_hab_manager)
	_connect_hab_manager()

	await get_tree().process_frame
	await get_tree().process_frame
	_setup_viewport()
	clear()
	
	map_visualizer.tile_clicked.connect(_on_tile_clicked)
	map_visualizer.tile_hovered.connect(_on_map_tile_hovered)
	unit_info.hability_use_requested.connect(_on_hability_use_requested)

	cards_panel.confirmed.connect(_hab_manager.confirm)
	cards_panel.cancelled.connect(_hab_manager.cancel)
	deployment_box.unit_selected_for_deployment.connect(_on_card_selected_in_ui)

func _on_juego_terminado(nombre_ganador: String) -> void:
	ganador_actual = nombre_ganador
	transition_screen.play_end_game_transition(nombre_ganador)


func _on_transicion_terminada() -> void:	
	UiManager.cambiar_a_escena("finalizacion", {"nombre_ganador": ganador_actual})
	
func clear() -> void:
	cards_panel.clear()

func _setup_viewport() -> void:
	#var container_size = map_container.size
	#sub_viewport.size = Vector2i(container_size)

	sub_viewport.transparent_bg = true
	
#HABILITY RELATED FUNCTIONS----------------
func _connect_hab_manager() -> void:
	_hab_manager.targets_highlighted.connect(_on_hab_targets_highlighted)
	_hab_manager.confirm_requested.connect(_on_hab_confirm_requested)
	_hab_manager.hability_applied.connect(_on_hab_applied)
	_hab_manager.cancelled.connect(_on_hab_cancelled)


func _on_hab_targets_highlighted(targets: Array[Vector2i]) -> void:
	map_visualizer.highlight_cells(targets)


func _on_hab_confirm_requested(hab: HabilityRes, targets: Array[Vector2i], unit: UnitGame) -> void:
	_state = UnitState.HABILITY_ACTIVE
	map_visualizer.highlight_cells(targets)
	cards_panel.show_confirm_dialog(hab, targets, unit)

func _on_hability_use_requested(hab: HabilityRes) -> void:

	if _selected_tile == null or not _selected_tile.has_unit():
		return
	
	if not turn_manager.is_current_user_local():
		return

	_hab_manager.request(hab, _selected_coords, _selected_tile)
	_state = UnitState.HABILITY_ACTIVE 


func _on_hab_applied(_hab: HabilityRes, _targets: Array[Vector2i]) -> void:
	_state = UnitState.UNIT_SELECTED
	map_visualizer.clear_highlights()
	cards_panel.hide_confirm_dialog()
	
			
	#if _selected_tile != null and _selected_tile.has_unit():
		#cards_panel.paint_unit_info(_selected_tile)
		#unit_info.observe(_selected_tile.get_unit())
	




func _on_hab_cancelled() -> void:
	_state = UnitState.UNIT_SELECTED
	map_visualizer.clear_highlights()
	cards_panel.hide_confirm_dialog()

func _on_tile_clicked(coords: Vector2i, tile: TileGame) -> void:
	if turn_manager and turn_manager.is_deployment_phase:
		_try_deploy(coords)
		return

	match _state:
		UnitState.IDLE, UnitState.UNIT_SELECTED:
			_select_tile(coords, tile)

		UnitState.HABILITY_ACTIVE:
			if not _hab_manager.try_select_target(coords):
				_select_tile(coords, tile)

func _on_card_selected_in_ui(army_group: CardArmyGroup) -> void:
	_pending_deployment_group = army_group

func _on_map_tile_hovered(coords: Vector2i) -> void:
	if not turn_manager or not turn_manager.is_deployment_phase:
		return
	if _pending_deployment_group == null:
		if map_visualizer:
			map_visualizer.clear_deployment_preview()
		return
	
	if not turn_manager.is_current_user_local():
		return

	var result: Dictionary = map.calculate_deployment(
		turn_manager.get_current_user_number(),
		_pending_deployment_group.n,
		coords
	)
	map_visualizer.show_deployment_preview(result["tiles"], result["is_valid"])

func _try_deploy(coords: Vector2i) -> void:
	if _pending_deployment_group == null:
		return
	if not turn_manager:
		return
		
	if not turn_manager.is_current_user_local():
		return

	var current_user := turn_manager.get_current_user()
	if await turn_manager._on_deploy_group(current_user, _pending_deployment_group, coords):
		_pending_deployment_group = null


func _select_tile(coords: Vector2i, tile: TileGame) -> void:
	_selected_coords = coords
	_selected_tile   = tile
	map_visualizer.highlight_selected_cell(coords)
	
	cards_panel.paint_tile_info(tile)

	if tile.has_unit():
		_state = UnitState.UNIT_SELECTED
		cards_panel.paint_unit_info(tile)
		unit_info.observe(tile.get_unit())
	else:
		_state = UnitState.IDLE
		cards_panel.clear_unit_info()
