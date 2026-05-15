extends Node

var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var error_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var music_player_2: AudioStreamPlayer

var tiempo_ultimo_hover: int = 0
const COOLDOWN_HOVER_MS: int = 100 
const VOLUMEN_HOVER: float = -6.0  
const VOLUMEN_CLICK: float = -2.0  
const VOLUMEN_ERROR: float = -4.0
const VOLUMEN_MUSICA: float = -12.0

func _ready() -> void:
	hover_player = AudioStreamPlayer.new()
	hover_player.stream = preload("res://assets/sonidos/button_hover.wav")
	hover_player.volume_db = VOLUMEN_HOVER
	add_child(hover_player)
	
	click_player = AudioStreamPlayer.new()
	click_player.stream = preload("res://assets/sonidos/button_pressed.mp3")
	click_player.volume_db = VOLUMEN_CLICK
	add_child(click_player)
	
	error_player = AudioStreamPlayer.new()
	error_player.stream = preload("res://assets/sonidos/ui_error.wav")
	error_player.volume_db = VOLUMEN_ERROR
	add_child(error_player)

	music_player = AudioStreamPlayer.new()
	music_player.volume_db = VOLUMEN_MUSICA
	add_child(music_player)

	music_player_2 = AudioStreamPlayer.new()
	music_player_2.volume_db = -80.0
	add_child(music_player_2)
	
	get_tree().node_added.connect(_al_añadir_nodo)
	_conectar_nodos_existentes(get_tree().root)

func _al_añadir_nodo(nodo: Node) -> void:
	if nodo is BaseButton:
		if not nodo.mouse_entered.is_connected(play_hover):
			nodo.mouse_entered.connect(play_hover)
		if not nodo.pressed.is_connected(play_click):
			nodo.pressed.connect(play_click)

func _conectar_nodos_existentes(nodo: Node) -> void:
	_al_añadir_nodo(nodo)
	for hijo in nodo.get_children():
		_conectar_nodos_existentes(hijo)

func play_hover() -> void:
	var tiempo_actual = Time.get_ticks_msec()
	if tiempo_actual - tiempo_ultimo_hover < COOLDOWN_HOVER_MS:
		return
	tiempo_ultimo_hover = tiempo_actual
	hover_player.pitch_scale = randf_range(0.9, 1.1)
	hover_player.play()

func play_click() -> void:
	click_player.pitch_scale = randf_range(0.95, 1.05)
	click_player.play()

func play_error() -> void:
	error_player.pitch_scale = randf_range(0.98, 1.02)
	error_player.play()

func cambiar_musica(nueva_pista: AudioStream, duracion: float = 2.0) -> void:
	if music_player.stream == nueva_pista:
		return

	music_player_2.stream = nueva_pista
	music_player_2.volume_db = -80.0
	music_player_2.play()

	var tween = create_tween().set_parallel(true)
	tween.tween_property(music_player, "volume_db", -80.0, duracion)
	tween.tween_property(music_player_2, "volume_db", VOLUMEN_MUSICA, duracion)

	await tween.finished
	
	music_player.stop()
	var temp = music_player
	music_player = music_player_2
	music_player_2 = temp
