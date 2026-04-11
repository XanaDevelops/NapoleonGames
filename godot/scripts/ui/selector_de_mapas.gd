class_name MapSelectorMenu
extends Control

@export var escena_tarjeta_mapa: PackedScene = preload("res://scenes/map_card.tscn")

@onready var contenedor_mapas = $Panel/ScrollContainer/MapContainer 
@onready var boton_jugar: Button = $Iniciar 

var mapa_actual: MapRes = null
var tarjeta_actual_nodo: MapCard = null 

func _ready() -> void:
	if boton_jugar:
		boton_jugar.disabled = true 
		boton_jugar.pressed.connect(_al_presionar_boton_jugar)
		
	_cargar_mapas_del_usuario()

func _cargar_mapas_del_usuario() -> void:
	var mapas_disponibles = UserManager.obtener_mapas()
	
	if mapas_disponibles.is_empty():
		print("El usuario no tiene mapas desbloqueados.")
		return

	for recurso_mapa in mapas_disponibles:
		if recurso_mapa != null:
			_crear_tarjeta_para_mapa(recurso_mapa)

func _crear_tarjeta_para_mapa(recurso_mapa: MapRes) -> void:
	var nueva_tarjeta = escena_tarjeta_mapa.instantiate() as MapCard
	contenedor_mapas.add_child(nueva_tarjeta)
	nueva_tarjeta.configurar(recurso_mapa)
	nueva_tarjeta.mapa_seleccionado.connect(_al_seleccionar_tarjeta_mapa)

func _al_seleccionar_tarjeta_mapa(datos_mapa: MapRes, nodo_tarjeta: MapCard) -> void:
	if tarjeta_actual_nodo != null and is_instance_valid(tarjeta_actual_nodo):
		tarjeta_actual_nodo.marcar_como_seleccionado(false)
		
	tarjeta_actual_nodo = nodo_tarjeta
	tarjeta_actual_nodo.marcar_como_seleccionado(true)
	
	mapa_actual = datos_mapa
	if boton_jugar: boton_jugar.disabled = false 

func _al_presionar_boton_jugar() -> void:
	if mapa_actual:
		print("¡Iniciando partida en el mapa: " + mapa_actual.name + "!")
		GameManager.start_game(UserManager.jugador_1,
								   UserManager.jugador_2,
								   mapa_actual,
								   UserManager.jugador_1.obtener_ejercito_activo(), 
								   UserManager.jugador_2.obtener_ejercito_activo())
