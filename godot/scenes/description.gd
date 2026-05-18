extends PanelContainer

@export var descriptionLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func paint(text:String) -> void:
	self.descriptionLabel.text = text
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			queue_free()
			
