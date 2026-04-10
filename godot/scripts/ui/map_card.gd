class_name MapCard
extends PanelContainer

signal mapa_seleccionado(datos_mapa: MapRes, nodo_tarjeta: MapCard) 

@onready var etiqueta_nombre: Label = $VBoxContainer/NameLabel 
@onready var etiqueta_descripcion: Label = $VBoxContainer/DescLabel
@onready var mini_visualizador: MiniMapVisualizer = %MiniMap

var datos_del_mapa: MapRes

func _ready() -> void:
	marcar_como_seleccionado(false)

func configurar(recurso_mapa: MapRes) -> void:
	datos_del_mapa = recurso_mapa
	
	etiqueta_nombre.text = datos_del_mapa.name
	etiqueta_descripcion.text = datos_del_mapa.desc
		
	mini_visualizador.dibujar_mapa_preview(datos_del_mapa)

# Activa o desactiva el borde rojo dinámicamente
func marcar_como_seleccionado(esta_seleccionado: bool) -> void:
	if esta_seleccionado:
		var estilo_seleccionado = StyleBoxFlat.new()
		estilo_seleccionado.bg_color = Color(0.15, 0.15, 0.15, 1.0) 
		estilo_seleccionado.set_border_width_all(3)
		estilo_seleccionado.border_color = Color.RED
		add_theme_stylebox_override("panel", estilo_seleccionado)
	else:
		remove_theme_stylebox_override("panel")

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		mapa_seleccionado.emit(datos_del_mapa, self)
