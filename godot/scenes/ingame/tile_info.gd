extends Control 


@export var name_label:Label 
@export var texture_rect: TextureRect 
@export var height_label: Label
@export var cost_label: Label 
@export var position_label: Label
@export var description_button: Button 
@export var tile_info: PanelContainer

var _current_tile: TileGame = null
var _desc_handler: DescriptionButtonHandler
#var _drag: DraggablePanel
var dragging:bool = false
var offset :Vector2 = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	#_drag = DraggablePanel.new()
	#_drag.setup(tile_info)
		

func paint(selected_tile: TileGame) -> void:
	_current_tile = selected_tile
	self.name_label.text = selected_tile.get_tile_name()
	self.height_label.text =  str(selected_tile.get_height())
	self.cost_label.text =  str(selected_tile.get_tile_cost())
	self.texture_rect.texture = selected_tile.get_texture2D()
	self.position_label.text = "(%d,%d)" % [selected_tile._position.x, selected_tile._position.y]
	_desc_handler = DescriptionButtonHandler.new()
	_desc_handler.setup(
		description_button,
		tile_info,
		func(): return _current_tile.get_tile_desc() if _current_tile else ""
	)
