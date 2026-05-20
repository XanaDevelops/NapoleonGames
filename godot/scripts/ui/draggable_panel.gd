
class_name DraggablePanel
extends PanelContainer

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_dragging = event.pressed
		if event.pressed:
			_drag_offset = global_position - event.global_position
		get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseMotion and _dragging:
		global_position = event.global_position + _drag_offset
		var vp = get_viewport_rect().size
		global_position.x = clampf(global_position.x, 0, vp.x - size.x)
		global_position.y = clampf(global_position.y, 0, vp.y - size.y)
		get_viewport().set_input_as_handled()
