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
@export var tile_map_layer_exhausted: TileMapLayer
var _owner_id:int = -1
signal tile_clicked(coords: Vector2i, tile: TileGame)
signal tile_hovered(coords: Vector2i)
signal movement_requested(start_pos: Vector2i, end_pos: Vector2i)

var tileset: TileSet
var texture_to_source_id: Dictionary = {}

const TILE_SIZE_HEIGHT = 64 * 1.5
const TILE_SIZE_WIDTH = 55 * 1.5 

var current_mask_size: float
var current_mask_scale_x: float

@export var vfx_database: Dictionary[StringName, VFXEffectData] = {}

@export var vfx_scene: PackedScene
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

@export var camera:Camera2D
const ZOOM_MIN = Vector2(0.3, 0.3)
const ZOOM_MAX = Vector2(2.5, 2.5)
const ZOOM_STEP= 0.1
const PAN_SPEED= 10.0
var _is_panning:bool= false
		
func _setup_highlight_tiles() -> void:
	var tex := load(HIGHLIGHT_TEXTURE) as Texture2D
	_highlight_id = add_texture_to_tileset(tex)
	var owner_tex := load(OWNER_TEXTURE) as Texture2D
	_owner_id = add_texture_to_tileset(owner_tex)
	
	tile_map_layer_owner_p1.self_modulate = COLOR_OWNER_P1
	tile_map_layer_owner_p2.self_modulate = COLOR_OWNER_P2
	tile_map_layer_exhausted.self_modulate =  Color.BLACK

func _ready() -> void:
	
	current_mask_scale_x = float(TILE_SIZE_HEIGHT) / float(TILE_SIZE_WIDTH)
	current_mask_scale_x *= 0.95
	current_mask_size = 0.5 * 0.98
	
	tileset = _setup_tileset()
	for tml in [tile_map_layer_texture, tile_map_layer_units,
				tile_map_layer_selection, tile_map_layer_highlight, 
				tile_map_layer_deployment, tile_map_layer_hover, tile_map_layer_owner_p1, 
				tile_map_layer_owner_p2, tile_map_layer_exhausted]:
		tml.tile_set = tileset
	_setup_highlight_tiles()
	if GameManager.turn_manager!=null:
		GameManager.turn_manager.tick_turn.connect(_clear_selection)
	
	var units_mat = tile_map_layer_units.material as ShaderMaterial
	if units_mat != null:
		units_mat.set_shader_parameter("mask_size", current_mask_size)
		units_mat.set_shader_parameter("mask_scale_x", current_mask_scale_x)

	_connect_turn_manager()


func _connect_turn_manager() -> void:
	var turn_manager: TurnManager = GameManager.get_turn_manager()
	if turn_manager == null:
		return

	if not turn_manager.unit_moved.is_connected(_on_unit_moved):
		turn_manager.unit_moved.connect(_on_unit_moved)
	if not turn_manager.tile_draw_requested.is_connected(_on_tile_draw_requested):
		turn_manager.tile_draw_requested.connect(_on_tile_draw_requested)
	if not turn_manager.deployment_zone_updated.is_connected(_on_deployment_zone_updated):
		turn_manager.deployment_zone_updated.connect(_on_deployment_zone_updated)
	if not turn_manager.deployment_zone_cleared.is_connected(_on_deployment_zone_cleared):
		turn_manager.deployment_zone_cleared.connect(_on_deployment_zone_cleared)
	if not turn_manager.deployment_preview_cleared.is_connected(_on_deployment_preview_cleared):
		turn_manager.deployment_preview_cleared.connect(_on_deployment_preview_cleared)
	if not turn_manager.unit_removed.is_connected(_on_unit_removed):
		turn_manager.unit_removed.connect(_on_unit_removed)
	if not turn_manager.movement_enabled.is_connected(_on_movement_enabled):
		turn_manager.movement_enabled.connect(_on_movement_enabled)
		
	if not turn_manager.unit_refresh.is_connected(_refresh_unit_states):
		turn_manager.unit_refresh.connect(_refresh_unit_states)


func _on_unit_moved(start: Vector2i, end: Vector2i) -> void:
	plot_unit_moved(start, end)


func _on_tile_draw_requested(pos: Vector2i, tile: TileGame) -> void:
	draw_tile(pos.x, pos.y, tile)


func _on_deployment_zone_updated(tiles: Array[Vector2i]) -> void:
	show_deployment_zone(tiles)


func _on_deployment_zone_cleared() -> void:
	clear_deployment_zone()


func _on_deployment_preview_cleared() -> void:
	clear_deployment_preview()


func _on_unit_removed(pos: Vector2i, tile: TileGame) -> void:
	remove_unit(pos, tile)


func _on_movement_enabled() -> void:
	var turn_manager: TurnManager = GameManager.get_turn_manager()
	if turn_manager == null:
		return
	if not movement_requested.is_connected(turn_manager._on_unit_movement_requested):
		movement_requested.connect(turn_manager._on_unit_movement_requested)
	
	
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
		var unit = tile.get_unit()
		var unit_source_id = add_texture_to_tileset(tile.get_unit().get_texture2D())
		tile_map_layer_units.set_cell(coords, unit_source_id, Vector2i.ZERO)
		_add_unit_overlay(coords, tile.get_unit())
				
		if not unit.hit_received.is_connected(_on_unit_hit):
			unit.hit_received.connect(_on_unit_hit.bind(unit))
			
		
		if not unit.dodged.is_connected(_on_unit_dodged):
			unit.dodged.connect(_on_unit_dodged.bind(unit))
			
		if not unit.healed.is_connected(_on_unit_healed):
			unit.healed.connect(_on_unit_healed.bind(unit))

func _on_unit_hit(attack_type: AttackType, unit: UnitGame) -> void:
	
	await play_attack_vfx(unit.get_current_position(), attack_type)

func _on_unit_dodged(unit: UnitGame) -> void:
	
	await play_vfx(unit.get_current_position(), &"protect")

func _on_unit_healed(unit: UnitGame) -> void:
	
	await play_vfx(unit.get_current_position(), &"heal")
				
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
	var path = map._find_path(src, target)
	
	# Reutilizar el tile_map_layer_deplyoment 
	tile_map_layer_deployment.clear()
	tile_map_layer_deployment.self_modulate = Color(0.2, 0.5, 1.0, 0.6)
	for cell in path:
		tile_map_layer_deployment.set_cell(cell, _highlight_id, Vector2i.ZERO)
	
	await get_tree().create_timer(0.3).timeout
	
	tile_map_layer_units.erase_cell(src)
	
	var tex = texture_to_source_id[source_id]
	var sprite = Sprite2D.new()
	sprite.texture = tex
	add_child(sprite)
	sprite.position = tile_map_layer_texture.map_to_local(src)
	
	if _unit_overlays.has(src):
		_unit_overlays[src].visible = false
	
	for i in range(1, path.size()):
		var cell_pos = tile_map_layer_texture.map_to_local(path[i])
		var tween = create_tween()
		tween.tween_property(sprite, "position", cell_pos, 0.10)\
			 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tile_map_layer_deployment.erase_cell(path[i - 1])
	
	sprite.queue_free()
	tile_map_layer_deployment.clear()
	tile_map_layer_units.set_cell(target, source_id, Vector2i.ZERO)
	_move_unit_overlay(src, target)
	_unit_overlays[target].visible = true
	_move_owner_highlight(src, target)
	
func refresh_unit_died(coords: Vector2i):
	tile_map_layer_units.erase_cell(coords)
	_remove_unit_overlay(coords)
	tile_map_layer_owner_p1.erase_cell(coords)
	tile_map_layer_owner_p2.erase_cell(coords)

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
	# ZOOM using wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at_mouse(ZOOM_STEP, event.global_position)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at_mouse(-ZOOM_STEP, event.global_position)
			get_viewport().set_input_as_handled()
			return
		
		# Moving the map
		elif event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			get_viewport().set_input_as_handled()
			return
		
		# selection
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_panning:
				return
			var coords =  _get_map_coords(event.global_position)
			_handle_click(coords)
	
	elif event is InputEventMouseMotion:
		# panning
		if _is_panning:
			camera.position -= event.relative / camera.zoom
			get_viewport().set_input_as_handled()
			return
		
		# hover
		var coords := _get_map_coords(event.global_position)
		if coords != _last_hovered_tile:
			_last_hovered_tile = coords
			tile_hovered.emit(coords)
			_update_hover(coords)

func _get_map_coords(global_mouse_pos: Vector2) -> Vector2i:
	var canvas_transform = get_canvas_transform()
	var world_pos = canvas_transform.affine_inverse() * global_mouse_pos
	var local_pos = tile_map_layer_texture.to_local(world_pos)
	return tile_map_layer_texture.local_to_map(local_pos)
	
func _zoom_at_mouse(step: float, mouse_global_pos: Vector2) -> void:
	var old_zoom = camera.zoom
	var new_zoom = (old_zoom + Vector2(step, step)).clamp(ZOOM_MIN, ZOOM_MAX)
	
	if new_zoom == old_zoom:
		return
	
	
	var mouse_local = (mouse_global_pos - get_viewport().get_visible_rect().size / 2.0) / old_zoom
	camera.position += mouse_local * (1.0 - old_zoom.x / new_zoom.x)
	camera.zoom = new_zoom
	
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
	#en fase de despliegue no procesar seleccion
	#solo se permite la colocación de tropas
	var tm = GameManager.get_turn_manager()
	if tm != null and tm.is_deployment_phase:
		return
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
			current_accesible_moves = await map.get_accesible_moves(coords)
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
	

func play_attack_vfx(target_coords: Vector2i, attack_type: AttackType) -> void:
	if not attack_type:
		return
	play_vfx(target_coords, attack_type.name)


func play_vfx(target_coords: Vector2i, effect_name: StringName) -> void:
	if not vfx_scene or effect_name == &"":
		return

	var current_vfx: VFXEffectData = null
	
	if vfx_database.has(effect_name):
		current_vfx = vfx_database[effect_name] as VFXEffectData
		
	if current_vfx == null:
		print("Atención: No hay animación en el diccionario para el efecto: ", effect_name)
		return
	var overlay = _unit_overlays.get(target_coords)
	
	if overlay and is_instance_valid(overlay):
		overlay.visible = false
		print("setting univert_overlay to false", target_coords)
	var unit_texture_resized: Texture2D
	var source_id = tile_map_layer_units.get_cell_source_id(target_coords)
	
	if source_id != -1 and texture_to_source_id.has(source_id):
		unit_texture_resized = texture_to_source_id[source_id]
	else:
		var fallback_tex = PlaceholderTexture2D.new()
		fallback_tex.size = Vector2(TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
		unit_texture_resized = fallback_tex
		
	var vfx_instance = vfx_scene.instantiate()
	add_child(vfx_instance)
	vfx_instance.z_index = 100 
	
	var local_pos = tile_map_layer_units.map_to_local(target_coords)
	vfx_instance.position = local_pos
	
	vfx_instance.setup_vfx(unit_texture_resized, current_vfx, current_mask_size, current_mask_scale_x)
	await vfx_instance.vfx_finished
	if overlay and is_instance_valid(overlay):
		overlay.visible = true
		print("setting univert_overlay to true", target_coords)
		
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
	if tm == null or tm.turn_order.is_empty() or unit==null:
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

func center_camera(viewport_size: Vector2) -> void:
	camera.make_current()
	var celdas = tile_map_layer_texture.get_used_cells()
	if celdas.is_empty(): return
	
	var min_p = Vector2(INF, INF)
	var max_p = Vector2(-INF, -INF)
	for celda in celdas:
		var p = tile_map_layer_texture.map_to_local(celda)
		min_p.x = min(min_p.x, p.x)
		min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x)
		max_p.y = max(max_p.y, p.y)
	
	camera.position = (min_p + max_p) / 2.0
	var map_size = (max_p - min_p) + Vector2(TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
	var zoom_f = min(viewport_size.x / map_size.x, viewport_size.y / map_size.y) * 0.9
	camera.zoom = Vector2(zoom_f, zoom_f)

func _refresh_unit_states() -> void:
	tile_map_layer_exhausted.clear()
	var tm = GameManager.get_turn_manager()
	if tm == null:
		return
	var current_user = tm.get_current_user()
	
	for coords in _unit_overlays:
		var tile = map.get_tile_at(coords)
		if tile.has_unit():
			var unit = tile.get_unit()
			# Solo afectar unidades del jugador actual
			if unit._owner == current_user:
				var exhausted = not unit.has_pending_actions()
				if exhausted:
					tile_map_layer_exhausted.set_cell(coords, _highlight_id, Vector2i.ZERO)
