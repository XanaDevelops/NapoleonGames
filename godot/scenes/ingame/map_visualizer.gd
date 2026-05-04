class_name mapVisualizer
extends Node2D


var map: MapGame 
var _last_hovered_tile: Vector2i = Vector2i(-999, -999)


var selected_cell: Vector2i = Vector2i(-1, -1)
var current_accesible_moves: Array[Vector2i] = []

@export var tile_map_layer_texture: TileMapLayer
@export var tile_map_layer_units: TileMapLayer
@export var tile_map_layer_selection: TileMapLayer
@export var tile_map_layer_highlight: TileMapLayer
@export var tile_map_layer_deployment: TileMapLayer

signal tile_clicked(coords: Vector2i, tile: TileGame)
signal tile_hovered(coords: Vector2i)
signal movement_requested(start_pos: Vector2i, end_pos: Vector2i)

var tileset: TileSet
var texture_to_source_id: Dictionary = {}
enum HighlightType { MOVEMENT, ATTACK, SELECTED, SKILL }

var highlight_source_ids: Dictionary[HighlightType, int] = {}

const HIGHLIGHT_TEXTURES: Dictionary = {
	HighlightType.MOVEMENT: "res://assets/tiles/highlights/hl_move.png",
	HighlightType.ATTACK:   "res://assets/tiles/highlights/hl_attack.png",
	HighlightType.SELECTED: "res://assets/tiles/highlights/hl_selected.png",
}

const TILE_SIZE_HEIGHT = 64 * 1.5
const TILE_SIZE_WIDTH = 55 * 1.5 # TILE_SIZE_HEIGHT/2 * root(3)


func _setup_highlight_tiles() -> void:
	for type in HIGHLIGHT_TEXTURES.keys():
		var tex := load(HIGHLIGHT_TEXTURES[type]) as Texture2D
		highlight_source_ids[type] = add_texture_to_tileset(tex)
		
func _ready() -> void:
	tileset = _setup_tileset()
	for tml in [tile_map_layer_texture, tile_map_layer_units,
				tile_map_layer_selection, tile_map_layer_highlight, tile_map_layer_deployment]:
		tml.tile_set = tileset
	_setup_highlight_tiles()
	
func _setup_tileset() -> TileSet:
	var tileset = TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tileset.tile_layout = TileSet.TILE_LAYOUT_STACKED        
	tileset.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL  
	tileset.tile_size = Vector2i(TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
	return tileset
	
func _setup_map(map: MapGame):
	self.map = map
	for y in range(map._mapRes.tamY):
		for x in range(map._mapRes.tamX):
			draw_tile(x, y, map.get_tile_at(Vector2i(x, y)))
func set_map(map: MapGame) -> void:
	self.map = map   

func remove_unit(pos:Vector2i, tile:TileGame)-> void:
	var tile_source_id = add_texture_to_tileset(tile.get_texture2D())
	tile_map_layer_units.set_cell(pos, tile_source_id, Vector2i.ZERO)
	
func draw_tile(i: int, y: int, tile: TileGame) -> void:
	var coords = Vector2i(i, y)
	var tile_source_id = add_texture_to_tileset(tile.get_texture2D())
			
	tile_map_layer_texture.set_cell(coords, tile_source_id, Vector2i.ZERO)
	
	if tile.has_unit():
		var unit_source_id = add_texture_to_tileset(tile.get_unit().get_texture2D())
		tile_map_layer_units.set_cell(coords, unit_source_id, Vector2i.ZERO)

func add_texture_to_tileset(texture: Texture2D) -> int:
	for tex_id in texture_to_source_id.keys():
		if texture_to_source_id[tex_id] == texture:
			return tex_id
	
	var source_id = texture_to_source_id.size()
	var tile_set_source = TileSetAtlasSource.new()
	var texture_resized = texture
	
	if texture.get_height() != TILE_SIZE_HEIGHT:
		texture_resized = _scale_texture(texture)

	tile_set_source.texture = texture_resized
	tile_set_source.texture_region_size = Vector2i(texture_resized.get_width(), texture_resized.get_height())
	tile_set_source.create_tile(Vector2i.ZERO)
	
	tileset.add_source(tile_set_source, source_id)
	texture_to_source_id[source_id] = texture_resized
	return source_id
	
func _scale_texture(texture: Texture2D) -> ImageTexture:
	var img := texture.get_image()
	img.resize(TILE_SIZE_HEIGHT, TILE_SIZE_HEIGHT, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)


func plot_unit_moved(src: Vector2i, target: Vector2i) -> void:
	var source_id = tile_map_layer_units.get_cell_source_id(src)
	tile_map_layer_units.set_cell(target, source_id, Vector2i.ZERO)
	tile_map_layer_units.erase_cell(src)
		
func refresh_unit_died(coords: Vector2i):
	tile_map_layer_units.erase_cell(coords)


func highlight_selected_cell(pos: Vector2i) -> void:
	tile_map_layer_selection.clear()
	clear_highlights()
	tile_map_layer_selection.set_cell(pos, highlight_source_ids[HighlightType.SELECTED], Vector2i.ZERO)
	
func clear_highlights()-> void:
	tile_map_layer_highlight.clear()
	
func highlight_cells(positions: Array[Vector2i]):
	clear_highlights()
	for pos in positions: 
		tile_map_layer_highlight.set_cell(pos, highlight_source_ids[HighlightType.MOVEMENT], Vector2i.ZERO)

func show_deployment_zone(positions: Array[Vector2i]) -> void:
	tile_map_layer_deployment.clear()
	var source_id := highlight_source_ids[HighlightType.SELECTED]
	for pos in positions:
		tile_map_layer_deployment.set_cell(pos, source_id, Vector2i.ZERO)

func clear_deployment_zone() -> void:
	tile_map_layer_deployment.clear()

func show_deployment_preview(positions: Array[Vector2i], is_valid: bool) -> void:
	tile_map_layer_highlight.clear()
	var type := HighlightType.MOVEMENT if is_valid else HighlightType.ATTACK
	var source_id := highlight_source_ids[type]
	for pos in positions:
		tile_map_layer_highlight.set_cell(pos, source_id, Vector2i.ZERO)

func clear_deployment_preview() -> void:
	tile_map_layer_highlight.clear()
	_last_hovered_tile = Vector2i(-999, -999)

# --- Process & Input Handling ---
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pos = tile_map_layer_texture.to_local(event.global_position)
		var coords = tile_map_layer_texture.local_to_map(local_pos)
		_handle_click(coords)
		
	elif event is InputEventMouseMotion:
		var local_pos := tile_map_layer_texture.to_local(event.global_position)
		var coords := tile_map_layer_texture.local_to_map(local_pos)
		
		if coords != _last_hovered_tile:
			_last_hovered_tile = coords
			tile_hovered.emit(coords)

func _handle_click(coords: Vector2i) -> void:
	if not map._is_in_map_bounds(coords):
		_clear_selection()
		return
	var tile = map.get_tile_at(coords)
	
	if tile == null:
		_clear_selection()
		return
	
		
	emit_signal("tile_clicked", coords, tile)
	
	if selected_cell != Vector2i(-1, -1) and coords in current_accesible_moves:
		movement_requested.emit(selected_cell, coords)
		_clear_selection()
		return
	_process_selection(coords, tile)

func _process_selection(coords: Vector2i, clicked_tile: TileGame) -> void:
	selected_cell = coords
	highlight_selected_cell(coords)
	
	if clicked_tile.has_unit():
		var unit = clicked_tile.get_unit()
		
		if not unit.has_moved_this_turn:
			current_accesible_moves = map.get_accesible_moves(coords)
			highlight_cells(current_accesible_moves) # Renders movement range
		else:
			current_accesible_moves = []
			tile_map_layer_highlight.clear()
	else:
		current_accesible_moves = []
		tile_map_layer_highlight.clear()

func _clear_selection() -> void:
	selected_cell = Vector2i(-1, -1)
	current_accesible_moves = []
	tile_map_layer_selection.clear()
	tile_map_layer_highlight.clear()
