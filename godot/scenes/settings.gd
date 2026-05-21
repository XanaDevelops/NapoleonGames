extends Control


@export var mode_button:OptionButton
@export var resolution_button:OptionButton
const WINDOW_MODE_ARRAY: Array[String]= [
	"Pantalla completa",
	"Modo ventana",
	"Venta sin bordes",
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
	mode_button.item_selected.connect(_on_window_mode_selected)
	resolution_button.item_selected.connect(on_resolution_selected)

func add_window_mode_items() -> void:
	for window_mode in WINDOW_MODE_ARRAY:
		mode_button.add_item(window_mode)

func add_resolution_items()->void:
	for res in RESOLUTION_ARRAY:
		resolution_button.add_item("%dx%d" % [res.x, res.y])
func _on_window_mode_selected(idx:int) -> void:
	match idx:
		0:#fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:#fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:#fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:#fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			
			

func on_resolution_selected(idx:int )->void:
	DisplayServer.window_set_size(RESOLUTION_ARRAY[idx])
