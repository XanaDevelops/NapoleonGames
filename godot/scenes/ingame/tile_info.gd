extends Control 

@onready var name_label: Label =$HBoxContainer/VBoxContainer/NameLabel
@onready var texture_rect: TextureRect= $HBoxContainer/VBoxContainer/TextureRect
@onready var description_label : Label = $HBoxContainer/DescriptionContainer/DescriptionContainer/DescriptionLabel
@onready var description_text: Label = $HBoxContainer/DescriptionContainer/DescriptionContainer/DescriptionText
@onready var height_label: Label = $HBoxContainer/HBoxContainer/HeightLabel
@onready var cost_label: Label = $HBoxContainer/HBoxContainer/CostLabel

@onready var hbox: HBoxContainer= $ScrollContainer/TileInfo/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func paint(dict: Dictionary) -> void:
	self.name_label.text = dict["tile_name"]
	self.description_text.text = "Description"
	self.description_label.text= dict["tile_desc"]
	self.height_label.text=  "Altura: %d" % dict["height"]
	self.cost_label.text= "Coste: %d" % dict["move_cost"]
	self.texture_rect.texture= dict["texture"]
	_paint_mods(dict["mods"])
	
	


func _paint_mods(mods: Array[TileModRes]) -> void:
	pass
