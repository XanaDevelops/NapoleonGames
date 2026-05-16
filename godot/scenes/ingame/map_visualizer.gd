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
@export var tile_map_layer_hover:TileMapLayer
@export var tile_map_layer_owner_p1:TileMapLayer
@export var tile_map_layer_owner_p2:TileMapLayer
var _owner_id:int = -1
signal tile_clicked(coords: Vector2i, tile: TileGame)
signal tile_hovered(coords: Vector2i)
signal movement_requested(start_pos: Vector2i, end_pos: Vector2i)

var tileset: TileSet
var texture_to_source_id: Dictionary = {}


const TILE_SIZE_HEIGHT = 64 * 1.5
const TILE_SIZE_WIDTH = 55 * 1.5 # TILE_SIZE_HEIGHT/2 * root(3)

const UNIT_OVERLAY_SCENE= preload("res://scenes/unit_overlay.tscn")
var _unit_overlays:Dictionary = {}

const HIGHLIGHT_TEXTURE = "res://assets/tiles/highlights/hl_white.png"
const OWNER_TEXTURE = "res://assets/tiles/highlights/inner_hl.png"
var _highlight_id:int = -1
const COLOR_MOVEMENT = Color(0.0, 1.0, 0.0, 0.784)
const COLOR_SELECTED = Color.GOLDENROD
const COLOR_HOVER = Color.DIM_GRAY
const COLOR_DEPLOYMENT_VALID = Color(0.0, 1, 0.0, 0.6)
const COLOR_DEPLOYMENT_INVALID =Color.BROWN
const COLOR_DEPLOYMENT_ZONE = Color.DARK_CYAN

const COLOR_OWNER_P1 = Color(0.2, 0.4, 1.0, 0.6)   
const COLOR_OWNER_P2 = Color(1.0, 0.2, 0.2, 0.6) 
		
func _setup_highlight_tiles() -> void:
	var tex := load(HIGHLIGHT_TEXTURE) as Texture2D
	_highlight_id = add_texture_to_tileset(tex)
	var owner_tex := load(OWNER_TEXTURE) as Texture2D
	_owner_id = add_texture_to_tileset(owner_tex)
	
	tile_map_layer_owner_p1.self_modulate = COLOR_OWNER_P1
	tile_map_layer_owner_p2.self_modulate = COLOR_OWNER_P2
	
func _ready() -> void:
	tileset = _setup_tileset()
	for tml in [tile_map_layer_texture, tile_map_layer_units,
				tile_map_layer_selection, tile_map_layer_highlight, 
				tile_map_layer_deployment, tile_map_layer_hover, tile_map_layer_owner_p1, tile_map_layer_owner_p2]:
		tml.tile_set = tileset
	_setup_highlight_tiles()
	if GameManager.turn_manager!=null:
		GameManager.turn_manager.tick_turn.connect(_clear_selection)
	
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
	_remove_unit_overlay(pos)
func draw_tile(i: int, y: int, tile: TileGame) -> void:
	var coords = Vector2i(i, y)
	var tile_source_id = add_texture_to_tileset(tile.get_texture2D())
			
	tile_map_layer_texture.set_cell(coords, tile_source_id, Vector2i.ZERO)
	_set_owner_highlight(Vector2i(i,y), tile._unit)
	if tile.has_unit():
		var unit_source_id = add_texture_to_tileset(tile.get_unit().get_texture2D())
		tile_map_layer_units.set_cell(coords, unit_source_id, Vector2i.ZERO)
		_add_unit_overlay(coords, tile.get_unit())
		
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
	_move_unit_overlay(src, target)
	_move_owner_highlight(src, target)
		
func refresh_unit_died(coords: Vector2i):
	tile_map_layer_units.erase_cell(coords)
	_remove_unit_overlay(coords)

func highlight_selected_cell(pos: Vector2i) -> void:
	tile_map_layer_selection.clear()
	clear_highlights()
	tile_map_layer_selection.self_modulate = COLOR_SELECTED
	tile_map_layer_selection.set_cell(pos, _highlight_id, Vector2i.ZERO)

func clear_highlights()-> void:
	tile_map_layer_highlight.clear()
	
func highlight_cells_owner(positions: Array[Vector2i], is_owner:bool) -> void:
	clear_highlights()
	if is_owner:
		tile_map_layer_highlight.self_modulate = COLOR_MOVEMENT
	else:
		tile_map_layer_highlight.self_modulate= Color.FIREBRICK
		
	for pos in positions:
		tile_map_layer_highlight.set_cell(pos, _highlight_id, Vector2i.ZERO)
		

func highlight_cells(positions: Array[Vector2i]) -> void:
	clear_highlights()
	tile_map_layer_highlight.self_modulate = COLOR_MOVEMENT

		
	for pos in positions:
		tile_map_layer_highlight.set_cell(pos, _highlight_id, Vector2i.ZERO)
		

func show_deployment_zone(positions: Array[Vector2i]) -> void:
	tile_map_layer_deployment.clear()
	tile_map_layer_deployment.self_modulate = COLOR_DEPLOYMENT_ZONE
	for pos in positions:
		tile_map_layer_deployment.set_cell(pos, _highlight_id, Vector2i.ZERO)

func clear_deployment_zone() -> void:
	tile_map_layer_deployment.clear()


func show_deployment_preview(positions: Array[Vector2i], is_valid: bool) -> void:
	tile_map_layer_highlight.clear()
	tile_map_layer_highlight.self_modulate = COLOR_DEPLOYMENT_VALID if is_valid else COLOR_DEPLOYMENT_INVALID
	for pos in positions:
		tile_map_layer_highlight.set_cell(pos, _highlight_id, Vector2i.ZERO)

func clear_deployment_preview() -> void:
	tile_map_layer_highlight.clear()
	_last_hovered_tile = Vector2i(-999, -999)

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
			_update_hover(coords)


func _update_hover(coords: Vector2i) -> void:
	tile_map_layer_hover.clear()
	tile_map_layer_hover.self_modulate = COLOR_HOVER
	if map._is_in_map_bounds(coords):
		tile_map_layer_hover.set_cell(coords, _highlight_id, Vector2i.ZERO)
func _handle_click(coords: Vector2i) -> void:
	if not map._is_in_map_bounds(coords):
		_clear_selection()
		return
	var tile = map.get_tile_at(coords)
	
	if tile == null:
		_clear_selection()
		return
	
		
	emit_signal("tile_clicked", coords, tile)
	#deseleccionar 
	if coords == selected_cell:
		_clear_selection()
		return
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
			var is_owner = GameManager.turn_manager.get_current_user()==clicked_tile._unit._owner
			highlight_cells_owner(current_accesible_moves, is_owner) # Renders movement range
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


func _add_unit_overlay(coords: Vector2i, unit: UnitGame) -> void:
	if _unit_overlays.has(coords):
		_unit_overlays[coords].cleanup()
	
	var overlay = UNIT_OVERLAY_SCENE.instantiate() as UnitOverlay
	add_child(overlay)
	overlay.setup(unit, coords, tile_map_layer_texture)
	_unit_overlays[coords] = overlay

func _remove_unit_overlay(coords: Vector2i) -> void:
	if _unit_overlays.has(coords):
		_unit_overlays[coords].cleanup()
		_unit_overlays.erase(coords)

func _move_unit_overlay(from: Vector2i, to: Vector2i) -> void:
	if _unit_overlays.has(from):
		var overlay = _unit_overlays[from]
		_unit_overlays.erase(from)
		overlay.update_coords(to)
		_unit_overlays[to] = overlay


func _set_owner_highlight(coords: Vector2i, unit: UnitGame) -> void:
	var tm = GameManager.get_turn_manager()
	if tm == null or tm.turn_order.is_empty():
		return
	if unit._owner == tm.turn_order[0]:
		tile_map_layer_owner_p1.set_cell(coords, _owner_id, Vector2i.ZERO)
	else:
		tile_map_layer_owner_p2.set_cell(coords, _owner_id, Vector2i.ZERO)

func _clear_owner_highlight(coords: Vector2i) -> void:
	tile_map_layer_owner_p1.erase_cell(coords)
	tile_map_layer_owner_p2.erase_cell(coords)

func _move_owner_highlight(from: Vector2i, to: Vector2i) -> void:
	
	if tile_map_layer_owner_p1.get_cell_source_id(from) != -1:
		tile_map_layer_owner_p1.erase_cell(from)
		tile_map_layer_owner_p1.set_cell(to, _owner_id, Vector2i.ZERO)
	elif tile_map_layer_owner_p2.get_cell_source_id(from) != -1:
		tile_map_layer_owner_p2.erase_cell(from)
		tile_map_layer_owner_p2.set_cell(to, _owner_id, Vector2i.ZERO)
