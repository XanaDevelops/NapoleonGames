extends PanelContainer


@export var cancel_button: Button
@export var yes_button: Button
@export var no_button: Button

func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel)
	yes_button.pressed.connect(_on_yes)
	no_button.pressed.connect(_on_no)

func _on_cancel() -> void:
	queue_free()

func _on_yes() -> void:
	get_tree().quit()

func _on_no() -> void:
	queue_free()
