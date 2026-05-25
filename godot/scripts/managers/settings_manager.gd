extends Node

const SETTINGS_PATH = "user://settings.cfg"

var settings = {
	"window_mode": 0,
	"resolution": 0,
	"volume_general": 1.0,
	"volume_music": 1.0,
	"volume_effects": 1.0,
	"fps": 60
}
const RESOLUTION_ARRAY:Array[Vector2i]= [
	Vector2i(1366,768),
	Vector2i(1280,720),
	Vector2i(1920,1080),
	Vector2i(1440,900),
	Vector2i(640,480)
]

func _ready():
	load_settings()
	apply_settings()

func save_settings():
	var config = ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return  # Usar los valores por defecto
	for key in settings:
		settings[key] = config.get_value("settings", key, settings[key])

func apply_settings():
	# Pantalla
	_on_window_mode_selected(settings["window_mode"])
	DisplayServer.window_set_size(RESOLUTION_ARRAY[settings["resolution"]])
	
	# Audio
	AudioServer.set_bus_volume_db(0, linear_to_db(settings["volume_general"]))
	AudioServer.set_bus_volume_db(1, linear_to_db(settings["volume_music"]))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings["volume_effects"]))
	
	# FPS
	Engine.max_fps = settings["fps"]

func _on_window_mode_selected(idx: int):
	match idx:
		0:	#pantalla completa
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

		1: #ventana
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

		2:#ventana sin bordes
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:#pantalla completa sin bordes
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
