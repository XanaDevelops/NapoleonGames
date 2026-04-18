extends Control


@onready var unit_label: Label = $VBoxContainer/VBoxContainer/UnitLabel
@onready var unit_texture: TextureRect = $VBoxContainer/VBoxContainer/UnitTextureRect
@onready var description_label: Label = $VBoxContainer/PanelContainer/HBoxContainer/DescriptionLabel
@onready var description_text: Label = $VBoxContainer/PanelContainer/HBoxContainer/DescriptionText
@onready var owner_label: Label = $VBoxContainer/VBoxContainer2/OwnerLabel
@onready var current_health_label : Label = $VBoxContainer/VBoxContainer2/CurrentHealthLabel
@onready var current_mana_label: Label = $VBoxContainer/VBoxContainer2/CurrentManaLabel
@onready  var speed_label: Label = $VBoxContainer/VBoxContainer2/SpeedLabel
@onready var dodge_label: Label = $VBoxContainer/VBoxContainer2/DodgeLabel
@onready var weight_label : Label = $VBoxContainer/VBoxContainer2/WeightLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    await get_tree().process_frame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    

func paint(dict: Dictionary) -> void:
    self.unit_label.text = dict["card_name"]
    self.description_text.text = "Description"
    self.description_label.text= dict["card_desc"]
    self.owner_label.text = "Owner: %s" %dict["card_owner"]
    self.weight_label.text=  "Altura: %d" % dict["card_weight"]
    self.unit_texture.texture= dict["card_portrait"]
    self.speed_label.text = "Speed : %d" % dict["card_speed"]
    self.dodge_label.text = "Dodge : %d" % dict["card_dodge"]
    self.current_health_label.text = "Current Health %d" %dict["card_currentHealth"]
    self.current_mana_label.text = "Current Health %d" %dict["card_currentMana"]
