extends PanelContainer

@export var nameLabel: Label
@export var RadiusLabel:Label
@export var ObjectiveLabel:Label
@export var ManaLabel:Label
@export var PassiveLabel:Label
@export var CoolDownLabel:Label
@export var DescriptionButton:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func paint(hab:HabilityRes) -> void:
	nameLabel.text = hab.name
	RadiusLabel.text= str(hab.radius)
	ObjectiveLabel.text = str(hab.objective)
	ManaLabel.text = str(hab.manaCost)
	CoolDownLabel.text= str(hab.cooldown)
	PassiveLabel.text = "SÍ" if hab.isPassive else "NO"
	DescriptionButton.pressed.connect(_on_description_requested)
	


func _on_description_requested() -> void:
	pass
