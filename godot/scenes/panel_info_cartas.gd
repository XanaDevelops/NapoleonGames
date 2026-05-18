extends Control

@export var tema_habilidad_basica: Theme
@export var tema_habilidad_especial: Theme

@onready var texto_desc: RichTextLabel = %TextoDescripciones
@onready var texto_stats: RichTextLabel = %TextoEstadisticas
@onready var titulo_habilidades: Label = %Habilidades

@onready var contenedor_botones: VBoxContainer = %ContenedorHabilidades
@onready var detalle_habilidad: RichTextLabel= %DetalleHabilidad
@onready var boton_volver:Button= %BotonVolver

var carta_actual: CardRes

func _ready() -> void:
	if detalle_habilidad: detalle_habilidad.hide()
	if boton_volver: 
		boton_volver.hide()
		boton_volver.pressed.connect(_on_boton_volver_pressed)

func cargar_carta(carta: CardRes) -> void:
	carta_actual = carta
	
	texto_desc.text = carta.desc
	
	# Afegim les etiquetes [b] i [/b] als títols
	texto_stats.text = "[b]HP:[/b] %d\n[b]Maná:[/b] %d\n[b]Velocidad:[/b] %d\n[b]Esquiva:[/b] %0.1f" % [
		carta.hp, carta.mana, carta.speed, carta.dodge
	]
	
	_generar_lista_habilidades()
	_mostrar_vista_lista()

func _generar_lista_habilidades() -> void:
	for child in contenedor_botones.get_children():
		child.queue_free()
	
	for hab in carta_actual.habilities:
		var btn = Button.new()
		btn.text = hab.name
		
		if hab.manaCost == 0:
			btn.theme = tema_habilidad_basica
		else:
			btn.theme = tema_habilidad_especial
			
		btn.pressed.connect(_on_habilidad_seleccionada.bind(hab))
		contenedor_botones.add_child(btn)

func _on_habilidad_seleccionada(hab: HabilityRes) -> void:
	contenedor_botones.hide()
	detalle_habilidad.show()
	boton_volver.show()
	
	titulo_habilidades.text = hab.name
	
	
	var info = "[b]Descripción:[/b] %s\n\n" % hab.desc
	
	
	info += "[b]Coste de Maná:[/b] [color=cyan]%d[/color]\n" % hab.manaCost
	info += "[b]Objetivo:[/b] %s\n" % hab._objective_text()
	
	if hab.stat:
		
		info += "[b]Efecto:[/b] [color=orange]%d en %s[/color]" % [hab.value, hab.stat.name]
	
	detalle_habilidad.text = info

func _on_boton_volver_pressed() -> void:
	_mostrar_vista_lista()

func _mostrar_vista_lista() -> void:
	contenedor_botones.show()
	detalle_habilidad.hide()
	boton_volver.hide()
	titulo_habilidades.text = "Habilidades"
