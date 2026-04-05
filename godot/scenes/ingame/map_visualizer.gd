class_name mapVisualizer
extends Node2D

#@export  var map:MapGame 
var map:MapGame 

@export var tile_map_layer_texture: TileMapLayer
@export var tile_map_layer_units: TileMapLayer
@export var tile_map_layer_selection: TileMapLayer
@export var tile_map_layer_highlight: TileMapLayer

var tileset: TileSet
var texture_to_source_id: Dictionary = {}
enum HighlightType { MOVEMENT, ATTACK, SELECTED, SKILL }

var highlight_source_ids: Dictionary[HighlightType, int] = {}

const HIGHLIGHT_TEXTURES: Dictionary = {
	HighlightType.MOVEMENT: "res://assets/tiles/highlights/hl_move.png",
	HighlightType.ATTACK:   "res://assets/tiles/highlights/hl_attack.png",
	HighlightType.SELECTED: "res://assets/tiles/highlights/hl_selected.png",
}
const TILE_SIZE_HEIGHT = 64*2
const TILE_SIZE_WIDTH = 55*2 # TILE_SIZE_HEIGHT/2 * root(3)
func _setup_highlight_tiles() -> void:
	for type in HIGHLIGHT_TEXTURES.keys():
		var tex := load(HIGHLIGHT_TEXTURES[type]) as Texture2D
		highlight_source_ids[type] = add_texture_to_tileset(tex)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map = GameManagerNode.get_map()
	if map == null:
		push_error("GameManager no tiene mapa, por ahora, usar el de test!!")
		map = TestMapGame.new().create_test_map()
		
	tileset = _setup_tileset()
	for tml in [tile_map_layer_texture, tile_map_layer_units,
				tile_map_layer_selection, tile_map_layer_highlight]:
		tml.tile_set = tileset
	_setup_highlight_tiles()
	_setup_map()
	
	
  
func _setup_tileset() -> TileSet:
	var tileset = TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tileset.tile_layout = TileSet.TILE_LAYOUT_STACKED        
	tileset.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL  
	tileset.tile_size = Vector2i(TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
	return tileset
	

func _setup_map():
	for y in range(map._mapRes.tamY):
		for x in range(map._mapRes.tamX):
			draw_tile(x, y, map.get_tile_at(Vector2i(x, y)))
			

func draw_tile(i: int, y:int, tile:TileGame) -> void:
	
		var coords = Vector2i(i, y)
		var tile_source_id = add_texture_to_tileset(tile.get_texture2D())
				
		tile_map_layer_texture.set_cell(coords, tile_source_id, Vector2i.ZERO)
		
		if tile.has_unit():
			var unit_source_id = add_texture_to_tileset(tile.get_unit().get_texture2D())
			tile_map_layer_units.set_cell(coords, unit_source_id, Vector2i.ZERO)

	
func add_texture_to_tileset(texture: Texture2D) -> int:
		for tex_id in texture_to_source_id.keys():
			if texture_to_source_id[tex_id]== texture:
				return tex_id
		
		var source_id = texture_to_source_id.size()
		var tile_set_source = TileSetAtlasSource.new()
		var texture_resized = texture
		if texture.get_height()!=TILE_SIZE_HEIGHT:
			texture_resized= _scale_texture(texture)

		tile_set_source.texture= texture_resized
		tile_set_source.texture_region_size= Vector2i(texture_resized.get_width(), texture_resized.get_height())
		tile_set_source.create_tile(Vector2i.ZERO)
		
		tileset.add_source(tile_set_source, source_id)
		texture_to_source_id[source_id]= texture_resized
		return source_id
	
func _scale_texture(texture: Texture2D) -> ImageTexture:
	var img := texture.get_image()
	img.resize(TILE_SIZE_HEIGHT, TILE_SIZE_HEIGHT, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)
	
func plot_unit_moved(src: Vector2i, target:Vector2i) -> void:
		var source_id = tile_map_layer_units.get_cell_source_id(src)
		tile_map_layer_units.set_cell(target, source_id, Vector2i.ZERO)
		tile_map_layer_units.erase_cell(src)
		
func refresh_unit_died(coords: Vector2i):
	tile_map_layer_units.erase_cell(coords)

func highlight_selected_cell(pos: Vector2i) -> void:
	tile_map_layer_selection.clear()
	tile_map_layer_selection.set_cell(pos, highlight_source_ids[HighlightType.SELECTED], Vector2i.ZERO)

func plot_mov_range(positions: Array[Vector2i]):
	tile_map_layer_highlight.clear()
	for pos in positions: 
		tile_map_layer_highlight.set_cell(pos, highlight_source_ids[HighlightType.MOVEMENT], Vector2i.ZERO)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#recibe señales
	#update stuff
	pass

				
	
