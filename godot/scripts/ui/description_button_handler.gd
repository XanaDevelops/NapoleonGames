class_name DescriptionButtonHandler
extends RefCounted

var _button: Button
var _anchor: Control  # nodo de referencia para posicionar el panel
var _get_text: Callable  # función que devuelve el texto

const DESCRIPTION_SCENE = preload("res://scenes/description.tscn")

func setup(button: Button, anchor: Control, get_text_callable: Callable) -> void:
	_button = button
	_anchor = anchor
	_get_text = get_text_callable
	
	for conn in _button.pressed.get_connections():
		_button.pressed.disconnect(conn.callable)
	_button.pressed.connect(_on_show_description)

func _on_show_description() -> void:
	var existing = _anchor.get_node_or_null("DescriptionPanel")
	if existing:
		existing.queue_free()
	
	var scene = DESCRIPTION_SCENE.instantiate()
	scene.name = "DescriptionPanel"
	_anchor.add_child(scene)
	scene.paint(_get_text.call())
	
	await _anchor.get_tree().process_frame
	scene.global_position = Vector2(
		_anchor.global_position.x + _anchor.size.x,
		_anchor.global_position.y - _anchor.size.y
	)
	print(_anchor.global_position)
	print(scene.global_position)
