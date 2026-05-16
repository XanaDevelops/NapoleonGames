extends Button
class_name CardUI

signal carta_seleccionada(carta_ui: CardUI)


enum HighlightMode {
	NONE,
	ORIGIN,
	AVAILABLE,
	SELECTED
}

@export var tema_por_defecto: Theme
@export var tema_origen: Theme
@export var tema_disponible: Theme
@export var tema_seleccionado: Theme


@onready var icono_carta = $ImageCard 
@onready var label_nombre = $VBoxContainer/Name
@onready var label_cantidad = $VBoxContainer/Quantity

var carta_res: CardRes
var en_mazo: bool = false 
var es_fantasma: bool = false

func _ready() -> void:
	pressed.connect(_al_pulsar)
	mouse_entered.connect(_on_mouse_interaction.bind(true))
	mouse_exited.connect(_on_mouse_interaction.bind(false))

func configurar(carta: CardRes, cantidad: int, es_mazo: bool) -> void:
	carta_res = carta
	en_mazo = es_mazo
	label_nombre.text = carta.name
	actualizar_cantidad(cantidad)
	if carta.img != null:
		icono_carta.texture = carta.img

func actualizar_cantidad(nueva_cantidad: int) -> void:
	label_cantidad.text = "x" + str(nueva_cantidad) if nueva_cantidad > 0 else ""


func set_highlight(mode: HighlightMode) -> void:
	match mode:
		HighlightMode.ORIGIN:
			theme = tema_origen
		HighlightMode.AVAILABLE:
			theme = tema_disponible
		HighlightMode.SELECTED:
			theme = tema_seleccionado
		HighlightMode.NONE, _:
			theme = tema_por_defecto

func _al_pulsar() -> void:
	carta_seleccionada.emit(self)

func _on_mouse_interaction(is_hover: bool) -> void:
	var target_scale = Vector2(1.05, 1.05) if is_hover else Vector2.ONE
	var target_mod = Color(1.2, 1.2, 1.2) if (is_hover and not es_fantasma) else Color.WHITE
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", target_scale, 0.1)
	tween.tween_property(self, "modulate", target_mod, 0.1)
