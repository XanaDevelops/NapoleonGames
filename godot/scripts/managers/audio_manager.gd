extends Node


var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var error_player: AudioStreamPlayer

var tiempo_ultimo_hover: int = 0
const COOLDOWN_HOVER_MS: int = 100 
const VOLUMEN_HOVER: float = -6.0  
const VOLUMEN_CLICK: float = -2.0  
const VOLUMEN_ERROR: float = -4.0

const VOLUMEN_MUSICA: float = -12.0
const VOLUMEN_MINIMO: float = -40.0

var music_players: Array[AudioStreamPlayer] = []
var active_player_idx: int = 0
var crossfade_duration: float = 2.0  
var fade_tween: Tween

var current_section: String = ""
var current_playlist: Array = []
var current_track_index: int = 0
var shuffle_enabled: bool = true

const VOLUMEN_SFX: float = -4.0
const MAX_SFX_PLAYERS: int = 5
var sfx_players: Array[AudioStreamPlayer] = []
var loaded_sfx: Dictionary = {} 

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

	for i in range(2):
		var player = AudioStreamPlayer.new()
		player.bus = "Music"
		add_child(player)
		music_players.append(player)
		player.finished.connect(_on_player_finished.bind(i))
	
	get_tree().node_added.connect(_al_añadir_nodo)
	_conectar_nodos_existentes(get_tree().root)
	
	for i in range(MAX_SFX_PLAYERS):
		var sfx_p = AudioStreamPlayer.new()
		sfx_p.volume_db = VOLUMEN_SFX
		add_child(sfx_p)
		sfx_players.append(sfx_p)
		
	
	for sfx_key in EscenasConfig.SFX_PATHS:
		var ruta = EscenasConfig.SFX_PATHS[sfx_key]
		if ResourceLoader.exists(ruta):
			loaded_sfx[sfx_key] = load(ruta)
		else:
			push_warning("[AudioManager] Archivo SFX no encontrado: " + ruta)
			
	await get_tree().process_frame
	_detectar_y_reproducir_escena_inicial()

func _detectar_y_reproducir_escena_inicial() -> void:
	if get_tree().current_scene:
		var ruta_actual = get_tree().current_scene.scene_file_path
		for identificador in EscenasConfig.MAPA_ESCENAS:
			if EscenasConfig.MAPA_ESCENAS[identificador] == ruta_actual:
				change_music_section_by_scene(identificador)
				return

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

func change_music_section_by_scene(scene_key: String) -> void:
	if not EscenasConfig.SECCIONES_POR_ESCENA.has(scene_key):
		push_warning("[AudioManager] Escena '%s' no encontrada en SECCIONES_POR_ESCENA." % scene_key)
		stop_music_with_fade()
		current_section = ""
		return
		
	var target_section = EscenasConfig.SECCIONES_POR_ESCENA[scene_key]
	
	if target_section.is_empty():
		stop_music_with_fade()
		current_section = ""
		return
		
	if current_section == target_section:
		return 
		
	_load_music_from_directory(target_section)

func _load_music_from_directory(section_name: String) -> void:
	if not EscenasConfig.MUSIC_SERIES_FOLDERS.has(section_name):
		push_error("[AudioManager] La sección '%s' no existe en MUSIC_SERIES_FOLDERS." % section_name)
		return
		
	current_section = section_name
	var dir_path = EscenasConfig.MUSIC_SERIES_FOLDERS[section_name]
	current_playlist = _get_audio_files_in_dir(dir_path)
	current_track_index = 0
	
	if current_playlist.is_empty():
		push_warning("[AudioManager] La carpeta está vacía: %s" % dir_path)
		return
		
	if shuffle_enabled and current_playlist.size() > 1:
		current_playlist.shuffle()
		
	_play_current_track(true) 

func _get_audio_files_in_dir(path: String) -> Array:
	var files = []
	if not path.ends_with("/"):
		path += "/"
		
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".ogg") or file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
					files.append(path + file_name)
				elif file_name.ends_with(".remap") or file_name.ends_with(".import"):
					var base_file = file_name.get_basename()
					if (base_file.ends_with(".ogg") or base_file.ends_with(".mp3") or base_file.ends_with(".wav")) and not files.has(path + base_file):
						files.append(path + base_file)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("[AudioManager] No se pudo acceder a la carpeta: %s" % path)
	return files

func _play_current_track(force_crossfade: bool = false) -> void:
	if current_playlist.is_empty():
		return
		
	var track_path = current_playlist[current_track_index]
	var stream = load(track_path)
	
	if not stream:
		_skip_to_next_track()
		return

	var old_player = music_players[active_player_idx]
	active_player_idx = (active_player_idx + 1) % 2
	var new_player = music_players[active_player_idx]
	
	new_player.stream = stream
	new_player.volume_db = VOLUMEN_MINIMO
	new_player.play()
	
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween().set_parallel(true)
	
	if old_player.playing:
		fade_tween.tween_property(old_player, "volume_db", VOLUMEN_MINIMO, crossfade_duration).set_trans(Tween.TRANS_SINE)
		fade_tween.chain().tween_callback(old_player.stop)
		
	fade_tween.tween_property(new_player, "volume_db", VOLUMEN_MUSICA, crossfade_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	print("[AudioManager] Reproduciendo: %s" % track_path.get_file())

func _skip_to_next_track() -> void:
	if current_playlist.is_empty():
		return
		
	current_track_index += 1
	if current_track_index >= current_playlist.size():
		current_track_index = 0
		if shuffle_enabled and current_playlist.size() > 1:
			current_playlist.shuffle()
			
	_play_current_track(false) 

func _on_player_finished(player_index: int) -> void:
	if player_index == active_player_idx:
		_skip_to_next_track()

func stop_music_with_fade() -> void:
	
	var reproduciendo_algo := false
	for player in music_players:
		if player.playing:
			reproduciendo_algo = true
			break
			
	
	if not reproduciendo_algo:
		return

	
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	fade_tween = create_tween().set_parallel(true)
	
	for player in music_players:
		if player.playing:
			fade_tween.tween_property(player, "volume_db", VOLUMEN_MINIMO, crossfade_duration).set_trans(Tween.TRANS_SINE)
			fade_tween.chain().tween_callback(player.stop)
			

func play_sfx(sfx_name: String) -> void:
	if not loaded_sfx.has(sfx_name):
		push_warning("[AudioManager] Intento de reproducir SFX desconocido: " + sfx_name)
		return
		
	
	var player_disponible: AudioStreamPlayer = null
	for p in sfx_players:
		if not p.playing:
			player_disponible = p
			break
			
	
	if player_disponible == null:
		player_disponible = sfx_players[0]
		
	
	player_disponible.stream = loaded_sfx[sfx_name]
	player_disponible.pitch_scale = randf_range(0.9, 1.1)
	player_disponible.play()
