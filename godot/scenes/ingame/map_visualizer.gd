class_name mapVisualizer
extends Node2D

#@export  var map:MapGame 
var map:MapGame 

@export var tile_map_layer_texture: TileMapLayer
@export var tile_map_layer_units: TileMapLayer

var tileset: TileSet
var texture_to_source_id: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#map = GameManagerNode.get_map()
	map = TestMapGame.create_test_map()  
	tileset= TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	tileset.tile_layout = TileSet.TILE_LAYOUT_STACKED        
	tileset.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL  
	tileset.tile_size = Vector2i(128, 128)
	tile_map_layer_texture.position = Vector2(-10, -10) 
	tile_map_layer_texture.tile_set= tileset
	tile_map_layer_units.tile_set = tileset
	setup_map()

func setup_map():
	#read tiles 
	for x in range(map._mapRes.tamX):
		for y in range(map._mapRes.tamY):
			draw_tile(x, y, map.get_tile_at(x, y))
			

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
		tile_set_source.texture= texture
		tile_set_source.texture_region_size= Vector2i(texture.get_width(), texture.get_height())
		tile_set_source.create_tile(Vector2i.ZERO)
		tileset.add_source(tile_set_source, source_id)
		texture_to_source_id[source_id]= texture
		return source_id	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
