class_name GameScene
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var players_panel: Control = $VBoxContainer/PlayersPanel
@onready var map_container: SubViewportContainer = $VBoxContainer/SubViewportContainer
@onready var cards_panel: Control = $VBoxContainer/CardsPanel
@onready var sub_viewport: SubViewport = $VBoxContainer/SubViewportContainer/SubViewport
@onready var map_visualizer: mapVisualizer= $VBoxContainer/SubViewportContainer/SubViewport/mapVisualizer

var map:MapGame 
func _ready() -> void:
    #vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)	
    if self.map == null:
        push_error("GameManager no tiene mapa, por ahora, usar el de test!!")
        self.map = TestMapGame.new().create_test_map()
        map_visualizer._setup_map(self.map)

    _setup_proportions()
    
    # Esperar un frame para que el layout calcule los tamaños reales
    await get_tree().process_frame
    _setup_viewport()
    map_visualizer.tile_clicked.connect(_on_tile_clicked)
    
func _setup_proportions() -> void:
    for panel in [players_panel, map_container, cards_panel]:
        panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    players_panel.size_flags_stretch_ratio = 0.5
    map_container.size_flags_stretch_ratio = 7.5
    cards_panel.size_flags_stretch_ratio   = 2.0
    players_panel.self_modulate = Color(1, 0, 0, 0.5)  
    map_container.self_modulate = Color(0, 1, 0, 0.5)  
    cards_panel.self_modulate   = Color(0, 0, 1, 0.5)

func _setup_viewport() -> void:
    # Sincronizar el SubViewport con el tamaño real del contenedor
    var size = Vector2i(map_container.size)
    sub_viewport.size = size

func _on_tile_clicked(coords: Vector2i, tile: TileGame) -> void:
    map_visualizer.highlight_selected_cell(coords)
    var tile_game = map.get_tile_at(coords)
    
    cards_panel.paint_tile_info(tile_game.get_info())
    if tile_game.has_unit():
        cards_panel.paint_unit_info(tile_game.get_unit_info())
