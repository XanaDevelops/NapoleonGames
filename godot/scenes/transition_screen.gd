extends CanvasLayer

@onready var main_container: Control = %MainConteiner

@onready var background: ColorRect = %Background
@onready var message_label: Label = %MessageLabel

@onready var coin_icon: Panel = %CoinIcon
@onready var coin_imatge: TextureRect = %CoinImatge

@onready var card_left: TextureRect = %CardLeft
@onready var card_right: TextureRect = %CardRight
@onready var sword_left: TextureRect = %SwordLeft
@onready var sword_right: TextureRect = %SwordRight

var orig_card_left_pos: Vector2
var orig_card_right_pos: Vector2
var orig_sword_left_pos: Vector2
var orig_sword_right_pos: Vector2
var orig_label_pos: Vector2

signal end_game_transition_finished 

func _ready() -> void:
	orig_label_pos=message_label.position
	orig_card_left_pos = card_left.position
	orig_card_right_pos = card_right.position
	orig_sword_left_pos = sword_left.position
	orig_sword_right_pos = sword_right.position
	
	hide()
	main_container.modulate.a = 0.0


func play_deployment_transition(first_player_name: String) -> void:
	_reset_elements()
	card_left.show()
	card_right.show()
	
	message_label.text = "Fase de Despliegue\nEmpieza " + first_player_name
	show()
	
	var tween = create_tween()
	
	tween.tween_callback(func(): AudioManager.play_sfx("card_deal"))
	
	
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	
	tween.parallel().tween_property(card_left, "rotation_degrees", -15.0, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card_left, "position:x", orig_card_left_pos.x - 60, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(card_right, "rotation_degrees", 15.0, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card_right, "position:x", orig_card_right_pos.x + 60, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(2.5)
	tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)


func play_combat_transition(first_player_name: String) -> void:
	_reset_elements()
	sword_left.show()
	sword_right.show()
	
	message_label.text = "¡Empieza el Combate!\nTurno de " + first_player_name
	show()
	
	var tween = create_tween()
	
	tween.tween_callback(func(): AudioManager.play_sfx("sword_swing"))
	
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	
	tween.parallel().tween_property(sword_left, "position:x", orig_sword_left_pos.x, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sword_right, "position:x", orig_sword_right_pos.x, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	
	var hit_tween = create_tween()
	hit_tween.tween_interval(0.4) 
	hit_tween.tween_callback(func(): AudioManager.play_sfx("sword_clash"))
	
	tween.tween_interval(2.5)
	tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)


func play_turn_transition(current_player_icon: Texture2D, next_player_name: String, next_player_icon: Texture2D) -> void:
	_reset_elements()
	coin_icon.show()
	
	coin_imatge.texture = current_player_icon
	message_label.text = "Turno de\n" + next_player_name
	show()
	
	var main_tween = create_tween()
	main_tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	
	var coin_tween = create_tween()
	var flip_speed = 0.35
	
	var play_flip_sound = func():
		AudioManager.play_sfx("coin_flip")
		

	var plano = Vector2(0.05, 1.0)
	var tamaño_real = Vector2(1.0, 1.0)
	
	
	coin_tween.tween_callback(play_flip_sound)
	coin_tween.tween_property(coin_icon, "scale", plano, flip_speed).set_trans(Tween.TRANS_SINE)
	coin_tween.tween_callback(func(): coin_imatge.texture = next_player_icon)
	coin_tween.tween_property(coin_icon, "scale", tamaño_real, flip_speed).set_trans(Tween.TRANS_SINE)
	

	coin_tween.tween_callback(play_flip_sound)
	coin_tween.tween_property(coin_icon, "scale", plano, flip_speed).set_trans(Tween.TRANS_SINE)
	coin_tween.tween_callback(func(): coin_imatge.texture = current_player_icon)
	coin_tween.tween_property(coin_icon, "scale", tamaño_real, flip_speed).set_trans(Tween.TRANS_SINE)
	
	
	coin_tween.tween_callback(play_flip_sound)
	coin_tween.tween_property(coin_icon, "scale", plano, flip_speed).set_trans(Tween.TRANS_SINE)
	coin_tween.tween_callback(func(): coin_imatge.texture = next_player_icon)
	coin_tween.tween_property(coin_icon, "scale", tamaño_real, flip_speed).set_trans(Tween.TRANS_SINE)
	
	main_tween.tween_interval(2.5)
	main_tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	main_tween.tween_callback(hide)

func play_turn_transition_fast(current_player_icon: Texture2D, next_player_name: String, next_player_icon: Texture2D) -> void:
	_reset_elements()
	coin_icon.show()
	
	coin_imatge.texture = current_player_icon
	message_label.text = "Turno de\n" + next_player_name
	show()
	
	var main_tween = create_tween()
	
	main_tween.tween_property(main_container, "modulate:a", 1.0, 0.3)
	
	var coin_tween = create_tween()
	var flip_speed = 0.35
	
	var play_flip_sound = func():
		if AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("coin_flip")
		
	var plano = Vector2(0.05, 1.0)
	var tamaño_real = Vector2(1.0, 1.0)
	
	# Único giro
	coin_tween.tween_callback(play_flip_sound)
	coin_tween.tween_property(coin_icon, "scale", plano, flip_speed).set_trans(Tween.TRANS_SINE)
	coin_tween.tween_callback(func(): coin_imatge.texture = next_player_icon)
	coin_tween.tween_property(coin_icon, "scale", tamaño_real, flip_speed).set_trans(Tween.TRANS_SINE)
	
	
	main_tween.tween_interval(1.2)
	
	
	main_tween.tween_property(main_container, "modulate:a", 0.0, 0.3)
	main_tween.tween_callback(hide)

func _reset_elements() -> void:
	coin_icon.hide()
	card_left.hide()
	card_right.hide()
	sword_left.hide()
	sword_right.hide()
	
	coin_icon.scale = Vector2(1.0, 1.0)
	
	card_left.rotation_degrees = 0.0
	card_left.position = orig_card_left_pos
	card_right.rotation_degrees = 0.0
	card_right.position = orig_card_right_pos
	
	sword_left.position = orig_sword_left_pos - Vector2(120, 0)
	sword_right.position = orig_sword_right_pos + Vector2(120, 0)
	


func play_end_game_transition(winner_name: String) -> void:
	_reset_elements()
	
	message_label.text = "¡Fin de la Partida!\nGanador: " + winner_name
	var screen_size = get_viewport().get_visible_rect().size
	message_label.position = (screen_size - message_label.size) / 2.0
	
	show()
	
	var tween = create_tween()
	
	tween.tween_callback(func(): AudioManager.play_sfx("victory_sound"))
	tween.tween_property(main_container, "modulate:a", 1.0, 0.5)
	tween.tween_interval(3.5) 
	tween.tween_callback(end_game_transition_finished.emit)
