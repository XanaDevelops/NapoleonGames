extends Control 


@onready var name_label = $PanelContainer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/NameLabel 
@onready var texture_rect: TextureRect = $PanelContainer/MarginContainer/PanelContainer/VBoxContainer/TextureRect
@onready var height_label: Label =$PanelContainer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/VBoxContainer/Panel2/HBoxContainer/HeightLabel
@onready var cost_label: Label =$PanelContainer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/VBoxContainer/Panel3/HBoxContainer/CostLabel
@onready var position_label: Label=$PanelContainer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/PositionLabel
@onready var description_button: Button = $CardsPanel/HBoxContainer/TileInfo/PanelContainer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/DescriptionButton


var _current_tile: TileGame = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	if description_button != null:
		description_button.pressed.connect(_show_description)

func paint(selected_tile: TileGame) -> void:
	_current_tile = selected_tile
	self.name_label.text = selected_tile.get_tile_name()
	self.height_label.text =  str(selected_tile.get_height())
	self.cost_label.text =  str(selected_tile.get_tile_cost())
	self.texture_rect.texture = selected_tile.get_texture2D()
	self.position_label.text = "(%d,%d)" % [selected_tile._position.x, selected_tile._position.y]

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
