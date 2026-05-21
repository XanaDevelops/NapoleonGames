class_name MiniMapVisualizer
extends Node2D

@export var max_zoom_width: float = 600.0
@export var max_zoom_height: float = 242.0

@onready var capa_tiles: TileMapLayer = $CapaTiles
@onready var camara: Camera2D = $Camera2D
# Referencia dinámica al tamaño del marco de la interfaz
@onready var viewport_padre: SubViewport = get_viewport()

var tileset: TileSet
var texture_to_source_id: Dictionary = {}

const TILE_SIZE_HEIGHT = 128 
const TILE_SIZE_WIDTH = 110  

func _ready() -> void:
	tileset = _crear_tileset()
	capa_tiles.tile_set = tileset

func _crear_tileset() -> TileSet:
	var ts = TileSet.new()
	ts.tile_shape = TileSet.TILE_SHAPE_HEXAGON
	ts.tile_layout = TileSet.TILE_LAYOUT_STACKED        
	ts.tile_offset_axis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL  
	ts.tile_size = Vector2i(TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
	return ts

func dibujar_mapa_preview(map_res: MapRes) -> void:
	capa_tiles.clear()
	texture_to_source_id.clear()
	
	if map_res == null:
		push_error("MiniMapVisualizer: map_res inyectado es nulo.")
		return
	
	for y in range(map_res.tamY):
		if y >= map_res.mapData.size(): continue
		var fila = map_res.mapData[y]
		
		for x in range(map_res.tamX):
			if x >= fila.size(): continue
			var tile_res = fila[x]
			
			if tile_res != null and tile_res.type != null:
				var textura: Texture2D = tile_res.type.texture
				
				if textura == null:
					continue
				
				var coords = Vector2i(x, y)
				var source_id = _anadir_textura(textura)
				capa_tiles.set_cell(coords, source_id, Vector2i.ZERO)
	
	# MODIFICACIÓN B: Llamamos a la función encargada de esperar a la UI
	_esperar_y_centrar()

func _esperar_y_centrar() -> void:
	# Esperamos dos frames completos para que todo el árbol de nodos de la UI 
	# calcule sus tamaños reales y finales (evita que devuelva 0x0)
	await get_tree().process_frame
	await get_tree().process_frame
	_centrar_camara()

func _anadir_textura(texture: Texture2D) -> int:
	if texture in texture_to_source_id.values():
		for id in texture_to_source_id:
			if texture_to_source_id[id] == texture: return id
	
	var source_id = texture_to_source_id.size()
	var tile_set_source = TileSetAtlasSource.new()
	
	var texture_resized = texture
	if texture.get_height() != TILE_SIZE_HEIGHT:
		var img := texture.get_image()
		img.resize(TILE_SIZE_HEIGHT, TILE_SIZE_HEIGHT, Image.INTERPOLATE_NEAREST)
		texture_resized = ImageTexture.create_from_image(img)

	tile_set_source.texture = texture_resized
	tile_set_source.texture_region_size = Vector2i(TILE_SIZE_HEIGHT, TILE_SIZE_HEIGHT)
	tile_set_source.create_tile(Vector2i.ZERO)
	
	tileset.add_source(tile_set_source, source_id)
	texture_to_source_id[source_id] = texture_resized
	return source_id

func _centrar_camara() -> void:
	camara.make_current()
	var celdas = capa_tiles.get_used_cells()
	if celdas.is_empty(): return
	
	var min_p = Vector2(INF, INF)
	var max_p = Vector2(-INF, -INF)
	for celda in celdas:
		var p = capa_tiles.map_to_local(celda)
		min_p.x = min(min_p.x, p.x); min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x); max_p.y = max(max_p.y, p.y)
	
	
	camara.position = (min_p + max_p) / 2.0
	
	
	var tam_mapa = (max_p - min_p) + Vector2(TILE_SIZE_WIDTH * 0.85, TILE_SIZE_HEIGHT * 0.95)
	
	
	var tamano_viewport = Vector2(viewport_padre.size)
	
	
	var ancho_disponible = tamano_viewport.x if tamano_viewport.x > 0 else max_zoom_width
	var alto_disponible = tamano_viewport.y if tamano_viewport.y > 0 else max_zoom_height
	
	
	var zoom_f = min(ancho_disponible / tam_mapa.x, alto_disponible / tam_mapa.y) * 0.98
	camara.zoom = Vector2(zoom_f, zoom_f)
