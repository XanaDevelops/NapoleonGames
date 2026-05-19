# phase_transition.gd
class_name PhaseTransition
extends RefCounted

const FADE_IN_DURATION = 0.7
const HOLD_DURATION = 3.0
const FADE_OUT_DURATION = 0.9

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
func show_battle_phase(user_a: UserGame, user_b: UserGame) -> void:
	var scene = load("res://scenes/battle_phase_banner.tscn").instantiate()
	scene.name = "PhaseBanner"
	scene.modulate.a = 0.0
	_root.add_child(scene)
	scene.paint(user_a, user_b)
	
	await _root.get_tree().process_frame
	
	var panel = scene.get_node("PanelContainer")
	var vp_size = scene.get_viewport_rect().size
	
	# Posición inicial fuera de pantalla por la izquierda
	var original_x = panel.global_position.x
	panel.global_position.x = -panel.size.x
	#tiempo de espera
	

	# Fade in + entrada desde izquierda
	var tween_in = scene.create_tween().set_parallel(true)
	tween_in.tween_property(scene, "modulate:a", 1.0, FADE_IN_DURATION)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_in.tween_property(panel, "global_position:x", original_x, 0.6)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween_in.finished
	await _root.get_tree().create_timer(HOLD_DURATION).timeout
	
	# Salida por la derecha + fade out
	var tween_out = scene.create_tween().set_parallel(true)
	tween_out.tween_property(panel, "global_position:x", vp_size.x, 0.5)\
			 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_out.tween_property(scene, "modulate:a", 0.0, 0.5)\
			 .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await tween_out.finished
	scene.queue_free()
