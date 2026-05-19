# phase_transition.gd
class_name PhaseTransition
extends RefCounted

const FADE_IN_DURATION = 0.4
const HOLD_DURATION = 2.0
const FADE_OUT_DURATION = 0.6

var _root: Node

func setup(root: Node) -> void:
	_root = root


func show_deployment_phase() -> void:
	var existing = _root.get_node_or_null("PhaseBanner")
	if existing:
		existing.queue_free()

	var scene = preload("res://scenes/deplyoment_animation.tscn").instantiate()
	scene.name = "PhaseBanner"
	scene.modulate.a = 0.0
	_root.add_child(scene)

	await _root.get_tree().process_frame

	# Buscar PlayersPanel desde TurnManager
	var players_panel = _root.get_node_or_null("IngameMap/PlayersPanel")
	if players_panel:
		scene.global_position = Vector2(
			players_panel.global_position.x+10,
			players_panel.global_position.y + players_panel.size.y*2
		)
	else:
		scene.global_position = Vector2(10, 60)

	var tween = scene.create_tween()
	tween.tween_property(scene, "modulate:a", 1.0, FADE_IN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_DURATION)
	tween.tween_property(scene, "modulate:a", 0.0, FADE_OUT_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(scene.queue_free)
