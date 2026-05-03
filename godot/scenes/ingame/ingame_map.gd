class_name GameScene
extends Control

@onready var vbox:          VBoxContainer        = $VBoxContainer
@onready var players_panel: Control              = $VBoxContainer/PlayersPanel
@onready var map_container: SubViewportContainer = $VBoxContainer/PanelContainer/SubViewportContainer

@onready var cards_panel:   Control              = $VBoxContainer/CardsPanel
@onready var sub_viewport:  SubViewport          = $VBoxContainer/PanelContainer/SubViewportContainer/SubViewport
@onready var map_visualizer: mapVisualizer       = $VBoxContainer/PanelContainer/SubViewportContainer/SubViewport/mapVisualizer
@onready var unit_info:     Control              = $VBoxContainer/CardsPanel/MarginContainer/TabContainer/UnitInfo

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
	map = GameManager.get_map()
	if map == null:
		push_error("GameScene: no tiene mapa — usando mapa de test")
		map = TestMapGame.new().create_test_map()
		GameManager.set_map(map)
	map_visualizer._setup_map(map)

	_hab_manager = HabilityManager.new()
	_connect_hab_manager()

	await get_tree().process_frame
	await get_tree().process_frame
	_setup_viewport()
	clear()
	map_visualizer.tile_clicked.connect(_on_tile_clicked)
	#GameManager.phase_changed.connect(_on_phase_change)
	#_on_phase_change(GameManager._app_state)
	unit_info.hability_use_requested.connect(_on_hability_use_requested)

	cards_panel.confirmed.connect(_hab_manager.confirm)
	cards_panel.cancelled.connect(_hab_manager.cancel)


#func _enter_battle()-> void:
	#unit_info.hability_use_requested.connect(_on_hability_use_requested)
	#cards_panel.confirmed.connect(_hab_manager.confirm)
	#cards_panel.cancelled.connect(_hab_manager.cancel)
	#cards_panel.set_phase_battle()
	#players_panel.set_phase_battle()
#
#func _enter_deployment() -> void:
	#players_panel.set_phase_deployment()
	#cards_panel.set_phase_deployment()
	#
	#
#func _on_phase_change(phase:GameManager.APP_STATE) -> void:
	#match phase:
		#GameManager.APP_STATE.DEPLOYMENT:
			#_enter_deployment()
		#GameManager.APP_STATE.IN_GAME:
			#_enter_battle()
func clear() -> void:
	cards_panel.clear()

func _setup_viewport() -> void:
	var container_size = map_container.size
	sub_viewport.size = Vector2i(container_size)

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

	_hab_manager.request(hab, _selected_coords, _selected_tile)
	_state = UnitState.HABILITY_ACTIVE 


func _on_hab_applied(_hab: HabilityRes, _targets: Array[Vector2i]) -> void:
	_state = UnitState.UNIT_SELECTED
	map_visualizer.clear_highlights()
	cards_panel.hide_confirm_dialog()



func _on_hab_cancelled() -> void:
	_state = UnitState.UNIT_SELECTED
	map_visualizer.clear_highlights()
	cards_panel.hide_confirm_dialog()

func _on_tile_clicked(coords: Vector2i, tile: TileGame) -> void:
	match _state:
		UnitState.IDLE, UnitState.UNIT_SELECTED:
			_select_tile(coords, tile)

		UnitState.HABILITY_ACTIVE:
			if not _hab_manager.try_select_target(coords):
				_select_tile(coords, tile)


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
