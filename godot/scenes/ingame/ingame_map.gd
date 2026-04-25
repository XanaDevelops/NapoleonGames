class_name GameScene
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var players_panel: Control = $VBoxContainer/PlayersPanel
@onready var map_container: SubViewportContainer = $VBoxContainer/SubViewportContainer
@onready var cards_panel: Control = $VBoxContainer/CardsPanel
@onready var sub_viewport: SubViewport = $VBoxContainer/SubViewportContainer/SubViewport
@onready var map_visualizer: mapVisualizer= $VBoxContainer/SubViewportContainer/SubViewport/mapVisualizer
@onready var unit_info: Control = $VBoxContainer/CardsPanel/MarginContainer/TabContainer/UnitInfo
enum UnitState{
	IDLE, UNIT_SELECTED, SELECTING_TARGET
}
var map:MapGame 
var _state: UnitState = UnitState.IDLE
var _selected_tile: TileGame = null
var _selected_coords: Vector2i = Vector2i(-1, -1)
var _pending_hab: HabilityRes = null

func _ready() -> void:
	if self.map == null:
		push_error("GameManager no tiene mapa, por ahora, usar el de test!!")
		self.map = TestMapGame.new().create_test_map()
		map_visualizer._setup_map(self.map)

	_setup_proportions()
	
	await get_tree().process_frame
	_setup_viewport()
	clear()
	map_visualizer.tile_clicked.connect(_on_tile_clicked)
	unit_info.hability_use_requested.connect(_on_hability_use_requested)


func clear() -> void:
	cards_panel.clear()
func _setup_proportions() -> void:
	for panel in [players_panel, map_container, cards_panel]:
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	players_panel.size_flags_stretch_ratio = 0.5
	map_container.size_flags_stretch_ratio = 7.5
	cards_panel.size_flags_stretch_ratio   = 2.0

func _setup_viewport() -> void:
	var size = Vector2i(map_container.size)
	sub_viewport.size = size

func _on_tile_clicked(coords: Vector2i, tile: TileGame) -> void:
	match _state:
		UnitState.IDLE, UnitState.UNIT_SELECTED:
			_select_tile(coords)
			
		UnitState.SELECTING_TARGET:
			_apply_hability_on_target(coords)

func _select_tile(coords: Vector2i) -> void:
	_selected_coords = coords
	_selected_tile = map.get_tile_at(coords)
	map_visualizer.highlight_selected_cell(coords)
	cards_panel.paint_tile_info(_selected_tile.get_info())
	
	if _selected_tile.has_unit():
		_state = UnitState.UNIT_SELECTED
		cards_panel._unit = _selected_tile.get_unit()
		cards_panel.paint_unit_info(_selected_tile.get_unit_info(),  _selected_tile.get_unit())
	else:
		_state = UnitState.IDLE
		cards_panel._unit = null

func _on_hability_use_requested(hab: HabilityRes) -> void:
	if _selected_tile == null or not _selected_tile.has_unit():
		return
	
	#if hab.objective == HabilityRes.HAB_DEST.SELF:
		#map.apply_hab(hab, _selected_coords, _selected_coords)
		#return

	_pending_hab = hab
	_state = UnitState.SELECTING_TARGET
	
	var targets = map.get_valid_targets(hab, _selected_coords, _selected_tile.get_unit())
	map_visualizer.plot_mov_range(targets)

func _apply_hability_on_target(target_coords: Vector2i) -> void:
	if _pending_hab == null:
		return
	
	var valid_targets = map.get_valid_targets(_pending_hab, _selected_coords, _selected_tile.get_unit())
	if target_coords not in valid_targets:
		
		_cancel_hability()
		return
	
	map.apply_hab(_pending_hab, _selected_coords, target_coords)
	
	_pending_hab = null
	_state = UnitState.UNIT_SELECTED
	map_visualizer.plot_mov_range([]) 

func _cancel_hability() -> void:
	_pending_hab = null
	_state = UnitState.UNIT_SELECTED
	map_visualizer.plot_mov_range([])
