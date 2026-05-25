class_name MapCard
extends Button

signal mapa_seleccionado(datos_mapa: MapRes, nodo_tarjeta: MapCard) 
signal mapa_confirmado_rapido(datos_mapa: MapRes) # NUEVA SEÑAL

@export var tema_normal: Theme
@export var tema_seleccion: Theme

@onready var etiqueta_nombre: RichTextLabel = %NameLabel 
@onready var etiqueta_descripcion: RichTextLabel = %DescLabel
@onready var mini_visualizador: MiniMapVisualizer = %MiniMap

var datos_del_mapa: MapRes

func _ready() -> void:
	marcar_como_seleccionado(false)
	pressed.connect(_al_ser_presionado)

func configurar(recurso_mapa: MapRes) -> void:
	datos_del_mapa = recurso_mapa
	etiqueta_nombre.text = "[center][b]" + datos_del_mapa.name + "[/b][/center]"
	etiqueta_descripcion.text = "[color=#d1d1d1]" + datos_del_mapa.desc + "[/color]"
	mini_visualizador.dibujar_mapa_preview(datos_del_mapa)

func marcar_como_seleccionado(esta_seleccionado: bool) -> void:
	if esta_seleccionado and tema_seleccion:
		theme = tema_seleccion
	elif not esta_seleccionado and tema_normal:
		theme = tema_normal

func _al_ser_presionado() -> void:
	mapa_seleccionado.emit(datos_del_mapa, self)


func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.double_click:
			mapa_confirmado_rapido.emit(datos_del_mapa)
