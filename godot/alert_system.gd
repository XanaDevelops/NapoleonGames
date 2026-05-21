extends Panel

@export var message_label: Label

func paint(message: String) -> void:
	message_label.text = message
