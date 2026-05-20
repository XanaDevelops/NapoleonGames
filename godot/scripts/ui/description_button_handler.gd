class_name DescriptionButtonHandler
extends RefCounted

var _button: Button
var _anchor: Control
var _get_text: Callable

const DESCRIPTION_SCENE = preload("res://scenes/description.tscn")

func setup(button: Button, anchor: Control, get_text_callable: Callable) -> void:
	_button = button
	_anchor = anchor
	_get_text = get_text_callable
	
	for conn in _button.pressed.get_connections():
		_button.pressed.disconnect(conn.callable)
	_button.pressed.connect(_on_show_description)

func _on_show_description() -> void:
	# Eliminar panel existente del root
	var root = _anchor.get_tree().root
	var existing = root.get_node_or_null("DescriptionPanel")
	if existing:
		existing.queue_free()
		return
	
	var scene = DESCRIPTION_SCENE.instantiate()
	scene.name = "DescriptionPanel"
	
	# Añadir al root para que esté por encima de todo
	root.add_child(scene)
	scene.paint(_get_text.call())
	
	# Esperar DOS frames para que el tamaño esté calculado
	await _anchor.get_tree().process_frame
	await _anchor.get_tree().process_frame
	
	var anchor_global = _anchor.global_position
	var anchor_size = _anchor.size
	var scene_size = scene.size
	var vp_size = _anchor.get_viewport_rect().size
	
	# Posición base: a la derecha del anchor
	var pos = Vector2(
		anchor_global.x + anchor_size.x + 5,
		anchor_global.y
	)
	
	# Ajustar si se sale por la derecha
	if pos.x + scene_size.x > vp_size.x:
		pos.x = anchor_global.x - scene_size.x - 5
	
	# Ajustar si se sale por abajo
	if pos.y + scene_size.y > vp_size.y:
		pos.y = vp_size.y - scene_size.y
	
	scene.global_position = pos
	
	# Cerrar al clicar fuera
	scene.set_meta("closeable", true)
