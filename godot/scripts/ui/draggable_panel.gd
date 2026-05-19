
class_name DraggablePanel
extends RefCounted

var _panel: Control
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func setup(panel: Control) -> void:
	_panel = panel
	panel.gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_dragging = event.pressed
		if event.pressed:
			_drag_offset = _panel.global_position - event.global_position
		_panel.get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseMotion and _dragging:
		_panel.global_position = event.global_position + _drag_offset
		_clamp_to_viewport()
		_panel.get_viewport().set_input_as_handled()

func _clamp_to_viewport() -> void:
	var vp = _panel.get_viewport_rect().size
	_panel.global_position.x = clampf(_panel.global_position.x, 0, vp.x - _panel.size.x)
	_panel.global_position.y = clampf(_panel.global_position.y, 0, vp.y - _panel.size.y)
