extends PanelContainer

@export var nameLabel: Label
@export var RadiusLabel:Label
@export var ObjectiveLabel:Label
@export var ManaLabel:Label
@export var PassiveLabel:Label
@export var CoolDownLabel:Label
#@export var DescriptionButton:Button
@export var description_label: Label
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
	description_label.text= hab.desc if hab.desc!=null else "No description"
	
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			queue_free()
			
