extends Control 

@onready var name_label: Label =$MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var texture_rect: TextureRect= $MarginContainer/HBoxContainer/VBoxContainer/TextureRect
@onready var description_label : Label = $MarginContainer/HBoxContainer/DescriptionContainer/DescriptionContainer/DescriptionLabel
@onready var description_text: Label = $MarginContainer/HBoxContainer/DescriptionContainer/DescriptionContainer/ScrollContainer/DescriptionText
@onready var height_label: Label = $MarginContainer/HBoxContainer/HBoxContainer/HeightLabel
@onready var cost_label: Label = $MarginContainer/HBoxContainer/HBoxContainer/CostLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    await get_tree().process_frame
    #description_label.custom_minimum_size = $MarginContainer/HBoxContainer/DescriptionContainer.size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func paint(dict: Dictionary) -> void:
    self.name_label.text = dict["tile_name"]
    self.description_label.text = "Description"
    self.description_text.text= dict["tile_desc"]
    self.height_label.text=  "Altura: %d" % dict["height"]
    self.cost_label.text= "Coste: %d" % dict["move_cost"]
    self.texture_rect.texture= dict["texture"]
    _paint_mods(dict["mods"])
    
    


func _paint_mods(mods: Array[TileModRes]) -> void:
    pass
