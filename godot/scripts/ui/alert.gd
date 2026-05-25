
class_name Alert
extends RefCounted

const ALERT_SCENE = preload("res://scenes/alert_system.tscn")
const DURATION = 2.0

var _root: Node

func setup(root: Node) -> void:
	_root = root

func show_alert(tile_pos: Vector2i, message: String ) -> void:
	var scene = ALERT_SCENE.instantiate()
	_root.add_child(scene)
	scene.paint(message)
	
	# Posicionar cerca del tile
	await _root.get_tree().process_frame
	
	# Convertir coords del mapa a posición en pantalla
	var map_vis = GameManager.get_turn_manager().get_node("IngameMap/SubViewportContainer/SubViewport/mapVisualizer") as mapVisualizer
	if map_vis:
		var world_pos = map_vis.tile_map_layer_texture.map_to_local(tile_pos)
		var screen_pos = map_vis.get_canvas_transform() * world_pos
		scene.global_position = screen_pos - Vector2(scene.size.x / 2.0, scene.size.y + 10)
	
	# Desaparecer después de DURATION segundos
	var tween = scene.create_tween()
	tween.tween_interval(DURATION - 0.5)
	tween.tween_property(scene, "modulate:a", 0.0, 0.5)
	tween.tween_callback(scene.queue_free)
