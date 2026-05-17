extends Control 

#@onready var name_label: Label =$MarginContainer/HBoxContainer/VBoxContainer/NameLabel
#@onready var texture_rect: TextureRect= $MarginContainer/HBoxContainer/VBoxContainer/TextureRect
#@onready var height_label: Label = $MarginContainer/HBoxContainer/HBoxContainer/HeightLabel
#@onready var cost_label: Label = $MarginContainer/HBoxContainer/HBoxContainer/CostLabel
#@onready var position_label: Label= $MarginContainer/HBoxContainer/HBoxContainer/PositionLabel
#@onready var description_button: Button= $MarginContainer/HBoxContainer/DescriptionButton

@export var name_label: Label 
@export var texture_rect: TextureRect
@export var height_label: Label 
@export var cost_label: Label 
@export var position_label: Label
@export var description_button: Button


var _current_tile: TileGame = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	description_button.pressed.connect(_show_description)

func paint(selected_tile: TileGame) -> void:
	_current_tile = selected_tile
	self.name_label.text = selected_tile.get_tile_name()
	self.height_label.text = "Altura: %d" % selected_tile.get_height()
	self.cost_label.text = "Coste: %d" % selected_tile.get_tile_cost()
	self.texture_rect.texture = selected_tile.get_texture2D()
	self.position_label.text = "Position: (%d,%d)" % [selected_tile._position.x, selected_tile._position.y]

func _show_description() -> void:
	if _current_tile == null:
		return
	var dialog = AcceptDialog.new()
	dialog.title = "Tile Description"
	dialog.dialog_text = _current_tile.get_tile_desc()
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
func _paint_mods(mods: Array[TileModRes]) -> void:
	pass
