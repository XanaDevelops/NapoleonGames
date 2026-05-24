class_name AlertSystem
extends Panel

@export var message_label: Label

enum MessageType { NORMAL, ERROR }

const THEME_NORMAL = preload("res://assets/themes/ui/aviso_normal.tres")
const THEME_ERROR = preload("res://assets/themes/ui/aviso_error.tres")
const OFFSET = Vector2(12, 12)  # separación respecto al cursor

func _ready() -> void:
	visible = false
	

func show_message(text: String, type: MessageType = MessageType.NORMAL) -> void:
	self.message_label.text = text
	theme = THEME_NORMAL if type == MessageType.NORMAL else THEME_ERROR
	visible = true
	_adjust_position()
	await get_tree().create_timer(2.0).timeout
	visible = false

func _adjust_position() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Esperar un frame para que el panel calcule su tamaño real
	await get_tree().process_frame
	
	var pos = mouse_pos + OFFSET
	
	# Evitar que se salga por la derecha
	if pos.x + size.x > viewport_size.x:
		pos.x = mouse_pos.x - size.x - OFFSET.x
	
	# Evitar que se salga por abajo
	if pos.y + size.y > viewport_size.y:
		pos.y = mouse_pos.y - size.y - OFFSET.y
	
	global_position = pos
