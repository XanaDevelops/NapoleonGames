extends Button
class_name CardUI

signal click_simple(nodo_carta: CardUI)
signal doble_click(nodo_carta: CardUI)
signal click_derecho(nodo_carta: CardUI)

@onready var image_card = $ImageCard
@onready var name_label = $VBoxContainer/Name
@onready var quantity_label = $VBoxContainer/Quantity

var mi_carta_res: CardRes

func _ready() -> void:
	button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT

func configurar(carta: CardRes, cantidad: int) -> void:
	mi_carta_res = carta
	name_label.text = carta.name
	quantity_label.text = "x" + str(cantidad)
	
	if carta.img != null:
		image_card.texture = carta.img

func actualizar_cantidad(nueva_cantidad: int) -> void:
	quantity_label.text = "x" + str(nueva_cantidad)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				doble_click.emit(self)
			else:
				click_simple.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			click_derecho.emit(self)
