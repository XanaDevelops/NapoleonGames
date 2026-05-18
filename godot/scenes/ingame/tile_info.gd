extends Control 


@export var name_label:Label 
@export var texture_rect: TextureRect 
@export var height_label: Label
@export var cost_label: Label 
@export var position_label: Label
@export var description_button: Button 
@export var tile_info: PanelContainer

var _current_tile: TileGame = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
		

func paint(selected_tile: TileGame) -> void:
	_current_tile = selected_tile
	self.name_label.text = selected_tile.get_tile_name()
	self.height_label.text =  str(selected_tile.get_height())
	self.cost_label.text =  str(selected_tile.get_tile_cost())
	self.texture_rect.texture = selected_tile.get_texture2D()
	self.position_label.text = "(%d,%d)" % [selected_tile._position.x, selected_tile._position.y]
	for conn in description_button.pressed.get_connections():
			description_button.pressed.disconnect(conn.callable)
		
	description_button.pressed.connect(_on_show_description)
func _on_show_description() -> void:
	var existing = get_node_or_null("TileDescription")
	if existing:
		existing.queue_free()
	
	var description_scene = preload("res://scenes/description.tscn").instantiate()
	description_scene.name = "TileDescription"
	add_child(description_scene)
	description_scene.paint(_current_tile.get_tile_desc())
	
	# Posicionar al lado derecho del UnitInfo
	await get_tree().process_frame
	var grid_global = tile_info.global_position
	var grid_height = tile_info.size.y
	description_scene.global_position = Vector2(grid_global.x , grid_global.y-grid_height)
