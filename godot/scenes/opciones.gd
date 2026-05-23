extends Button

@export var contenerDeMenu:VBoxContainer
@export var panel_settings: Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_settings.visible= false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	contenerDeMenu.visible= false
	panel_settings.visible= true
