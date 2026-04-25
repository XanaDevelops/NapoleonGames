class_name GameScene
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var players_panel: Control = $VBoxContainer/PlayersPanel
@onready var map_container: SubViewportContainer = $VBoxContainer/SubViewportContainer
@onready var cards_panel: Control = $VBoxContainer/CardsPanel
@onready var sub_viewport: SubViewport = $VBoxContainer/SubViewportContainer/SubViewport
@onready var map_visualizer: mapVisualizer= $VBoxContainer/SubViewportContainer/SubViewport/mapVisualizer
@onready var unit_info: Control = $VBoxContainer/CardsPanel/MarginContainer/TabContainer/UnitInfo

var map:MapGame 
var selected_coords: Vector2i
func _ready() -> void:
	#vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)	
	if self.map == null:
		push_error("GameManager no tiene mapa, por ahora, usar el de test!!")
		self.map = TestMapGame.new().create_test_map()
		map_visualizer._setup_map(self.map)

	_setup_proportions()
	selected_coords =Vector2i(-1,-1)
	
	# Esperar un frame para que el layout calcule los tamaños reales
	await get_tree().process_frame
	_setup_viewport()
	clear()
	map_visualizer.tile_clicked.connect(_on_tile_clicked)
	unit_info.hability_use_requested.connect(_on_hability_use_requested)


func _on_hability_use_requested(hab: HabilityRes) -> void:
	if selected_coords==null or selected_coords==Vector2i(-1,-1):
		push_error("Error of empty/null coordinates") 
	#get the range of movments of the hability..
	movs = 
	print("usar habilidad: ", hab.name)
		
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
	selected_coords= coords
	map_visualizer.highlight_selected_cell(coords)
	var tile_game = map.get_tile_at(coords)
	
	cards_panel.paint_tile_info(tile_game.get_info())
	
	if tile_game.has_unit():
		cards_panel._unit = tile_game.get_unit() 
		cards_panel.paint_unit_info(tile_game.get_unit_info())
		
	else:
		cards_panel._unit = null 
