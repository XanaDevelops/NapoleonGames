extends Control

@export var mode_button: OptionButton
@export var resolution_button: OptionButton
@export var volumGeneral: HSlider
@export var volumMusic: HSlider
@export var volumEffects: HSlider
@export var fps_option:OptionButton
@export var vsync_button:CheckButton
const FPS_OPTIONS = [30, 60, 120, 144, 240, 0]

const WINDOW_MODE_ARRAY: Array[String]= [
	"Pantalla completa",
	"Modo ventana",
	"Ventana sin bordes",
	"Pantalla completa sin bordes"
]

const RESOLUTION_ARRAY:Array[Vector2i]= [
	Vector2i(1366,768),
	Vector2i(1280,720),
	Vector2i(1920,1080),
	Vector2i(1440,900),
	Vector2i(640,480)
]

func _ready():
	add_window_mode_items()
	add_resolution_items()
	add_fps_options()
	# Carga los valores guardados en los controles UI
	_load_ui_from_settings()
	
	# Conectar las señales
	mode_button.item_selected.connect(_on_window_mode_selected)
	resolution_button.item_selected.connect(_on_resolution_selected)
	volumGeneral.value_changed.connect(_on_value_changed.bind(0, "volume_general"))
	volumMusic.value_changed.connect(_on_value_changed.bind(1, "volume_music"))
	volumEffects.value_changed.connect(_on_value_changed.bind(2, "volume_effects"))
	fps_option.item_selected.connect(_on_fps_selected)
	vsync_button.toggled.connect(_on_check_button_toggled)

func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		mode_button.add_item(window_mode)

func add_resolution_items()->void:
	for res in RESOLUTION_ARRAY:
		resolution_button.add_item("%dx%d" % [res.x, res.y])


func _load_ui_from_settings():
	var s = SettingsManager.settings
	mode_button.select(s["window_mode"])
	resolution_button.select(s["resolution"])
	volumGeneral.value = s["volume_general"]
	volumMusic.value = s["volume_music"]
	volumEffects.value = s["volume_effects"]
	fps_option.select(FPS_OPTIONS.find(s["fps"]))
	
	

func _on_window_mode_selected(idx: int):
	SettingsManager.settings["window_mode"] = idx
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_resolution_selected(idx: int):
	SettingsManager.settings["resolution"] = idx
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_value_changed(value: float, bus_index: int, key: String):
	SettingsManager.settings[key] = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	SettingsManager.save_settings()


func _on_check_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
	)
	SettingsManager.settings["vsync"] = toggled_on  
	SettingsManager.save_settings()
		
func _on_fps_selected(idx: int) -> void:
	var fps = FPS_OPTIONS[idx]
	Engine.max_fps = fps
	SettingsManager.settings["fps"] = fps
	SettingsManager.save_settings()
	
func add_fps_options():
	for fps in FPS_OPTIONS:
		var label = "Sin límite" if fps==0 else str(fps)
		fps_option.add_item(label)
