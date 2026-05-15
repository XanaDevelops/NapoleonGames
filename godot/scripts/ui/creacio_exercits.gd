extends Control

@export var carta_interfaz: PackedScene 
@export var aviso_normal: Theme
@export var aviso_error: Theme 
@export var tema_pestaña_normal: Theme
@export var tema_pestaña_activa: Theme

@onready var contenedor_cartas_disponibles = %ContenedorCartasDisponibles
@onready var contenedor_mazo = %ContenedorMazo
@onready var label_peso = %LabelPeso
@onready var input_nombre_ejercito = %LineEditNombreEjercito

@onready var boton_guardar = %BotonGuardarEjercito
@onready var boton_nuevo = %BotonNuevo
@onready var boton_eliminar = %BotonEliminar
@onready var boton_revertir = %BotonRevertir 
@onready var fila_botones_mazos = %FilaBotonesMazos

@onready var panel_transferencia = %PanelTransferencia
@onready var panel_spinner = %PanelSpinner 
@onready var boton_menos = %BotonMenos
@onready var boton_mas = %BotonMas
@onready var label_cantidad = %LabelCantidad
@onready var boton_confirmar = %Confirmar
@onready var boton_cancelar = %Cancelar
@onready var label_aviso = %LabelAviso 
@onready var panel_info_cartas = %PanelInfoCartas

var ejercito_actual: ArmyRes
var nombre_original_ejercito: String = ""

var interfaz_disponibles: Dictionary = {}
var interfaz_mazo: Dictionary = {} 

var carta_origen: CardRes = null
var interfaz_origen: CardUI = null 
var grupo_origen: CardArmyGroup = null
var hacia_mazo: bool = true
var cantidad_transferencia: int = 1
var limite_transferencia: int = 0
var destino_listo: bool = false
var interfaz_destino: CardUI = null

var tween_vibracion: Tween
var tween_feedback: Tween 

var memoria_nodos: Array = []
var memoria_colores: Array = []

func _ready() -> void:
	boton_guardar.pressed.connect(_pulsar_guardar)
	boton_nuevo.pressed.connect(_pulsar_nuevo)
	boton_eliminar.pressed.connect(_pulsar_eliminar)
	boton_revertir.pressed.connect(_pulsar_revertir)
	
	boton_menos.pressed.connect(_pulsar_menos)
	boton_mas.pressed.connect(_pulsar_mas)
	boton_confirmar.pressed.connect(_confirmar_transferencia)
	boton_cancelar.pressed.connect(_cancelar_transferencia)
	
	panel_transferencia.visible = false
	
	UserManager.usuario_cambiado.connect(_al_cambiar_usuario)
	
	_cargar_datos_usuario()
	
func _al_cambiar_usuario(_nuevo_email: String) -> void:
	_cargar_datos_usuario()

func _cargar_datos_usuario() -> void:
	
	var ejercitos = UserManager.obtener_ejercitos()
	if ejercitos.is_empty():
		_pulsar_nuevo()
	else:
		var indice_activo = 0
		for i in range(ejercitos.size()):
			if ejercitos[i].isActive:
				indice_activo = i
				break
		_seleccionar_ejercito(indice_activo)
		
	_cancelar_transferencia()

func _restaurar_texto_guia() -> void:
	if not panel_transferencia.visible: return
	
	label_aviso.theme = aviso_normal
	
	if not destino_listo:
		label_aviso.text = "¡Elige un hueco amarillo de destino!"
	else:
		label_aviso.text = "¿Cuántas tropas quieres mover?"

func _lanzar_error_narrador(mensaje: String) -> void:
	if tween_feedback and tween_feedback.is_valid(): 
		tween_feedback.kill()
	
	tween_feedback = create_tween()
	label_aviso.text = mensaje
	label_aviso.theme = aviso_error
	
	_vibrar_nodos([label_aviso])
	
	tween_feedback.tween_interval(1.5)
	tween_feedback.tween_callback(_restaurar_texto_guia)

func _son_misma_carta(carta1: CardRes, carta2: CardRes) -> bool:
	if carta1 == null or carta2 == null: 
		return false
	return carta1.name == carta2.name

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if carta_origen != null:
			_cancelar_transferencia()

func _al_seleccionar_carta(nodo: CardUI) -> void:
	if nodo == interfaz_origen:
		_cancelar_transferencia()
		return
	
	panel_info_cartas.cargar_carta(nodo.carta_res)
	panel_info_cartas.show()
		
	var es_mismo_tipo = (carta_origen != null) and _son_misma_carta(nodo.carta_res, carta_origen)
	
	if es_mismo_tipo and (nodo.en_mazo == hacia_mazo):
		_seleccionar_destino(nodo)
	else:
		_iniciar_transferencia(nodo)

func _iniciar_transferencia(nodo_origen: CardUI) -> void:
	_limpiar_resaltados()
	carta_origen = nodo_origen.carta_res
	interfaz_origen = nodo_origen
	hacia_mazo = not nodo_origen.en_mazo
	destino_listo = false
	interfaz_destino = null
	
	grupo_origen = interfaz_mazo.get(nodo_origen, null) if not hacia_mazo else null
	
	nodo_origen.set_highlight(CardUI.HighlightMode.ORIGIN) 
	
	if hacia_mazo: 
		_resaltar_destinos_en_mazo(carta_origen)
	else: 
		_resaltar_destinos_en_disponibles(carta_origen)
	
	panel_transferencia.visible = true
	boton_menos.disabled = false
	boton_mas.disabled = false
	boton_confirmar.disabled = false
	label_cantidad.text = "-"
	label_peso.modulate = Color.WHITE
	_restaurar_texto_guia()
	
	if not hacia_mazo:
		for nodo in interfaz_disponibles.values():
			if is_instance_valid(nodo) and _son_misma_carta(nodo.carta_res, carta_origen):
				_seleccionar_destino(nodo)
				break

func _seleccionar_destino(nodo_destino: CardUI) -> void:
	var nodos_disponibles = interfaz_mazo.keys() if hacia_mazo else interfaz_disponibles.values()
	
	for nodo in nodos_disponibles:
		if is_instance_valid(nodo) and _son_misma_carta(nodo.carta_res, carta_origen):
			nodo.set_highlight(CardUI.HighlightMode.AVAILABLE)
				
	destino_listo = true
	interfaz_destino = nodo_destino
	nodo_destino.set_highlight(CardUI.HighlightMode.SELECTED) 
	
	cantidad_transferencia = 1
	_calcular_limites_movimiento()
	
	if limite_transferencia > 0:
		label_cantidad.text = str(cantidad_transferencia)  
		_actualizar_texto_peso_teorico()
	else:
		cantidad_transferencia = 0 
		label_cantidad.text = "0"
		_restaurar_texto_guia()

func _cancelar_transferencia() -> void:
	carta_origen = null
	interfaz_origen = null
	grupo_origen = null
	interfaz_destino = null
	destino_listo = false
	panel_transferencia.visible = false
	label_peso.modulate = Color.WHITE
	_actualizar_texto_peso() 
	_limpiar_resaltados()
	panel_info_cartas.hide()

func _resaltar_destinos_en_mazo(carta: CardRes) -> void:
	for nodo in interfaz_mazo.keys():
		if is_instance_valid(nodo) and _son_misma_carta(nodo.carta_res, carta):
			nodo.set_highlight(CardUI.HighlightMode.AVAILABLE)
			
	var hueco = carta_interfaz.instantiate() as CardUI
	contenedor_mazo.add_child(hueco)
	hueco.configurar(carta, 0, true)
	hueco.es_fantasma = true
	hueco.modulate = Color(1, 1, 1, 0.5)
	hueco.set_highlight(CardUI.HighlightMode.AVAILABLE)
	hueco.carta_seleccionada.connect(_al_seleccionar_carta)
	interfaz_mazo[hueco] = null 

func _resaltar_destinos_en_disponibles(carta: CardRes) -> void:
	var encontrado = false
	for nodo in interfaz_disponibles.values():
		if is_instance_valid(nodo) and _son_misma_carta(nodo.carta_res, carta):
			nodo.set_highlight(CardUI.HighlightMode.AVAILABLE)
			encontrado = true
			
	if not encontrado:
		var hueco = carta_interfaz.instantiate() as CardUI
		contenedor_cartas_disponibles.add_child(hueco)
		hueco.configurar(carta, 0, false)
		hueco.es_fantasma = true
		hueco.modulate = Color(1, 1, 1, 0.5)
		hueco.set_highlight(CardUI.HighlightMode.AVAILABLE)
		hueco.carta_seleccionada.connect(_al_seleccionar_carta)
		interfaz_disponibles[carta] = hueco

func _limpiar_resaltados() -> void:
	var todos_los_nodos = interfaz_mazo.keys() + interfaz_disponibles.values()
	for nodo in todos_los_nodos:
		if is_instance_valid(nodo):
			nodo.set_highlight(CardUI.HighlightMode.NONE)
			if nodo.es_fantasma: 
				if nodo.en_mazo: 
					interfaz_mazo.erase(nodo)
				else: 
					interfaz_disponibles.erase(nodo.carta_res)
				nodo.queue_free()

func _calcular_limites_movimiento() -> void:
	if hacia_mazo:
		var cartas_libres = _calcular_cartas_libres().get(carta_origen, 0)
		var peso_disponible = ArmyRes.MAX_SIZE - ejercito_actual.get_weight()
		var max_por_peso = floor(peso_disponible / carta_origen.weight) if carta_origen.weight > 0 else 99
		limite_transferencia = min(cartas_libres, max_por_peso)
	else:
		limite_transferencia = grupo_origen.n if grupo_origen != null else 0

func _pulsar_mas() -> void:
	if not destino_listo:
		_animar_error_destinos()
		return
		
	if cantidad_transferencia < limite_transferencia:
		cantidad_transferencia += 1
		label_cantidad.text = str(cantidad_transferencia)
		_actualizar_texto_peso_teorico()
	else:
		if hacia_mazo and carta_origen.weight > 0 and (ejercito_actual.get_weight() + ((cantidad_transferencia + 1) * carta_origen.weight) > ArmyRes.MAX_SIZE):
			_animar_error_peso()
		else: 
			_animar_error_limite()

func _pulsar_menos() -> void:
	if not destino_listo:
		_animar_error_destinos()
		return
		
	if cantidad_transferencia > 1:
		cantidad_transferencia -= 1
		label_cantidad.text = str(cantidad_transferencia)
		_actualizar_texto_peso_teorico()

func _actualizar_texto_peso_teorico() -> void:
	var peso_base = ejercito_actual.get_weight()
	var variacion_peso = carta_origen.weight * cantidad_transferencia
	var peso_modificado = peso_base + variacion_peso if hacia_mazo else peso_base - variacion_peso
	
	label_peso.text = "Peso: %d / %d" % [peso_modificado, ArmyRes.MAX_SIZE]
	label_peso.modulate = Color.YELLOW

func _vibrar_nodos(nodos: Array, es_error: bool = true) -> void:
	if tween_vibracion and tween_vibracion.is_valid():
		for i in range(memoria_nodos.size()):
			if is_instance_valid(memoria_nodos[i]):
				memoria_nodos[i].modulate = memoria_colores[i]
				memoria_nodos[i].rotation = 0.0
		tween_vibracion.kill()
		
	AudioManager.play_error()
	tween_vibracion = create_tween()
	memoria_nodos.clear()
	memoria_colores.clear()
	
	for nodo in nodos:
		if is_instance_valid(nodo):
			nodo.pivot_offset = nodo.size / 2.0
			memoria_nodos.append(nodo)
			memoria_colores.append(nodo.modulate) 
			
	if memoria_nodos.is_empty(): 
		return

	var duracion = 0.05
	
	for i in range(2):
		for j in range(memoria_nodos.size()):
			var nodo = memoria_nodos[j]
			var t_prop = tween_vibracion if j == 0 else tween_vibracion.parallel()
			t_prop.tween_property(nodo, "rotation", deg_to_rad(5), duracion)
			if es_error:
				tween_vibracion.parallel().tween_property(nodo, "modulate", Color.RED, duracion)

		for j in range(memoria_nodos.size()):
			var nodo = memoria_nodos[j]
			var t_prop = tween_vibracion if j == 0 else tween_vibracion.parallel()
			t_prop.tween_property(nodo, "rotation", deg_to_rad(-5), duracion)
			if es_error:
				tween_vibracion.parallel().tween_property(nodo, "modulate", memoria_colores[j], duracion)

	for j in range(memoria_nodos.size()):
		var nodo = memoria_nodos[j]
		var t_prop = tween_vibracion if j == 0 else tween_vibracion.parallel()
		t_prop.tween_property(nodo, "rotation", 0.0, duracion)
		if es_error:
			tween_vibracion.parallel().tween_property(nodo, "modulate", memoria_colores[j], duracion)

	tween_vibracion.tween_callback(func(): 
		tween_vibracion = null
		memoria_nodos.clear()
		memoria_colores.clear()
	)

func _animar_error_peso() -> void:
	_lanzar_error_narrador("¡EXCESO DE PESO!")
	_vibrar_nodos([label_peso, panel_spinner])

func _animar_error_destinos() -> void:
	_lanzar_error_narrador("¡FALTA ELEGIR DESTINO!")
	var nodos_disponibles = interfaz_mazo.keys() if hacia_mazo else interfaz_disponibles.values()
	var destinos = []
	for nodo in nodos_disponibles: 
		if is_instance_valid(nodo) and _son_misma_carta(nodo.carta_res, carta_origen): 
			destinos.append(nodo)
	
	var nodos_a_vibrar = [panel_spinner, boton_confirmar]
	nodos_a_vibrar.append_array(destinos)
	_vibrar_nodos(nodos_a_vibrar)

func _animar_error_limite() -> void:
	_lanzar_error_narrador("¡NO QUEDAN MÁS CARTAS!")
	_vibrar_nodos([panel_spinner, interfaz_origen])

func _animar_error_input(mensaje_placeholder: String) -> void:
	input_nombre_ejercito.text = ""
	input_nombre_ejercito.placeholder_text = mensaje_placeholder
	_vibrar_nodos([input_nombre_ejercito])
	
	if tween_feedback and tween_feedback.is_valid(): 
		tween_feedback.kill()
		
	tween_feedback = create_tween()
	tween_feedback.tween_interval(1.5)
	tween_feedback.tween_callback(func(): 
		input_nombre_ejercito.text = nombre_original_ejercito if nombre_original_ejercito != "" else ejercito_actual.nom
		input_nombre_ejercito.placeholder_text = ""
	)

func _exito_guardado() -> void:
	if tween_feedback and tween_feedback.is_valid(): 
		tween_feedback.kill()
		
	tween_feedback = create_tween()
	boton_guardar.pivot_offset = boton_guardar.size / 2.0
	var texto_original = boton_guardar.text
	boton_guardar.text = "¡Guardado!"
	
	tween_feedback.tween_property(boton_guardar, "modulate", Color.GREEN, 0.1)
	tween_feedback.parallel().tween_property(boton_guardar, "scale", Vector2(1.05, 1.05), 0.1)
	tween_feedback.tween_property(boton_guardar, "modulate", Color.WHITE, 0.2)
	tween_feedback.parallel().tween_property(boton_guardar, "scale", Vector2(1.0, 1.0), 0.2)
	tween_feedback.tween_interval(1.0)
	tween_feedback.tween_callback(func(): boton_guardar.text = texto_original)

func _confirmar_transferencia() -> void:
	if not destino_listo:
		_animar_error_destinos()
		return
	if cantidad_transferencia == 0:
		_animar_error_peso()
		return
		
	if hacia_mazo:
		var grupo_destino = interfaz_mazo.get(interfaz_destino, null)
		if grupo_destino != null: 
			grupo_destino.n += cantidad_transferencia
		else:
			var nuevo_grupo = CardArmyGroup.new()
			nuevo_grupo.cardType = carta_origen 
			nuevo_grupo.n = cantidad_transferencia       
			ejercito_actual.agrupations.append(nuevo_grupo)
	else:
		if grupo_origen != null:
			grupo_origen.n -= cantidad_transferencia
			if grupo_origen.n <= 0: 
				ejercito_actual.agrupations.erase(grupo_origen)
			
	_cancelar_transferencia() 
	_recargar_tablero()

func _recargar_tablero() -> void:
	_limpiar_tablero()
	for grupo in ejercito_actual.agrupations: 
		_instanciar_carta_mazo(grupo)
	_actualizar_cartas_libres_visuales()
	_actualizar_texto_peso()

func _instanciar_carta_mazo(grupo: CardArmyGroup) -> void:
	var nueva_carta = carta_interfaz.instantiate() as CardUI
	contenedor_mazo.add_child(nueva_carta)
	nueva_carta.configurar(grupo.cardType, grupo.n, true) 
	nueva_carta.carta_seleccionada.connect(_al_seleccionar_carta)
	interfaz_mazo[nueva_carta] = grupo

func _actualizar_cartas_libres_visuales() -> void:
	var cartas_restantes = _calcular_cartas_libres()
	for carta in cartas_restantes.keys():
		var cantidad = cartas_restantes[carta]
		if interfaz_disponibles.has(carta):
			var nodo = interfaz_disponibles[carta]
			if cantidad <= 0:
				nodo.queue_free()
				interfaz_disponibles.erase(carta)
			else: 
				nodo.actualizar_cantidad(cantidad)
		elif cantidad > 0:
			var nueva_carta = carta_interfaz.instantiate() as CardUI
			contenedor_cartas_disponibles.add_child(nueva_carta)
			nueva_carta.configurar(carta, cantidad, false) 
			nueva_carta.carta_seleccionada.connect(_al_seleccionar_carta)
			interfaz_disponibles[carta] = nueva_carta

func _calcular_cartas_libres() -> Dictionary:
	var inventario = UserManager.usuario_actual.availableCards.duplicate()
	for grupo in ejercito_actual.agrupations:
		for inv_carta in inventario.keys():
			if _son_misma_carta(inv_carta, grupo.cardType):
				inventario[inv_carta] -= grupo.n 
				break
	return inventario

func _limpiar_tablero() -> void:
	for nodo in interfaz_mazo.keys(): 
		if is_instance_valid(nodo): 
			nodo.queue_free()
	interfaz_mazo.clear()
	
	for nodo in interfaz_disponibles.values(): 
		if is_instance_valid(nodo): 
			nodo.queue_free()
	interfaz_disponibles.clear()

func _actualizar_texto_peso() -> void:
	label_peso.text = "Peso: %d / %d" % [ejercito_actual.get_weight(), ArmyRes.MAX_SIZE]

func _cargar_interfaz_inicial() -> void:
	_limpiar_tablero() 
	input_nombre_ejercito.text = ejercito_actual.nom
	for grupo in ejercito_actual.agrupations: 
		_instanciar_carta_mazo(grupo)
	_actualizar_cartas_libres_visuales()
	_actualizar_texto_peso()
	_actualizar_botones_mazos()
	panel_transferencia.visible = false
	carta_origen = null


func _actualizar_botones_mazos() -> void:
	
	for hijo in fila_botones_mazos.get_children(): 
		hijo.queue_free()
	
	var ejercitos = UserManager.obtener_ejercitos()
	var mazo_actual_esta_guardado = false
	
	for i in range(ejercitos.size()):
		var mazo = ejercitos[i]
		var nuevo_boton = Button.new()
		
		nuevo_boton.text = mazo.nom
		
		if ejercito_actual != null and mazo.nom == nombre_original_ejercito: 
			
			if tema_pestaña_activa:
				nuevo_boton.theme = tema_pestaña_activa
			mazo_actual_esta_guardado = true
			
		else:
			if tema_pestaña_normal:
				nuevo_boton.theme = tema_pestaña_normal
		
		nuevo_boton.pressed.connect(_seleccionar_ejercito.bind(i))
		fila_botones_mazos.add_child(nuevo_boton)
		
	if not mazo_actual_esta_guardado and ejercito_actual != null:
		var boton_fantasma = Button.new()
		boton_fantasma.text = "* " + ejercito_actual.nom + " *"
		
		if tema_pestaña_activa:
			boton_fantasma.theme = tema_pestaña_activa
			
		fila_botones_mazos.add_child(boton_fantasma)
	

func _seleccionar_ejercito(indice: int) -> void:
	var ejercitos = UserManager.obtener_ejercitos()
	ejercito_actual = ejercitos[indice].clonar()
	nombre_original_ejercito = ejercito_actual.nom 
	UserManager.establecer_ejercito_activo(ejercito_actual.nom)
	_cargar_interfaz_inicial()

func _generar_nombre_unico() -> String:
	var base = "Nuevo Ejército"
	var nombre = base
	var contador = 1
	while UserManager.existe_ejercito(nombre):
		contador += 1
		nombre = base + " " + str(contador)
	return nombre

func _pulsar_nuevo() -> void:
	ejercito_actual = ArmyRes.new()
	ejercito_actual.nom = _generar_nombre_unico()
	ejercito_actual.isActive = true 
	nombre_original_ejercito = "" 
	_cargar_interfaz_inicial()

func _pulsar_revertir() -> void:
	if UserManager.existe_ejercito(nombre_original_ejercito):
		var ejercitos = UserManager.obtener_ejercitos()
		for i in range(ejercitos.size()):
			if ejercitos[i].nom == nombre_original_ejercito:
				_seleccionar_ejercito(i)
				break
	else: 
		_pulsar_nuevo()

func _pulsar_eliminar() -> void:
	if UserManager.obtener_ejercitos().size() <= 1:
		_vibrar_nodos([boton_eliminar])
		return
		
	if nombre_original_ejercito != "":
		UserManager.eliminar_ejercito(nombre_original_ejercito)
		
	var ejercitos = UserManager.obtener_ejercitos()
	if ejercitos.is_empty(): 
		_pulsar_nuevo()
	else: 
		_seleccionar_ejercito(0)

func _pulsar_guardar() -> void:
	var nuevo_nombre = input_nombre_ejercito.text.strip_edges() 
	
	var nombre_invalido = nuevo_nombre.is_empty() or (nuevo_nombre != nombre_original_ejercito and UserManager.existe_ejercito(nuevo_nombre))
	if nombre_invalido or ejercito_actual.agrupations.is_empty():
		var mensaje = "¡Nombre en uso!" if UserManager.existe_ejercito(nuevo_nombre) else "¡Faltan tropas o nombre!"
		_animar_error_input(mensaje)
		return
		
	ejercito_actual.nom = nuevo_nombre
	ejercito_actual.isActive = true
	UserManager.guardar_ejercito(ejercito_actual, nombre_original_ejercito)
	UserManager.establecer_ejercito_activo(nuevo_nombre)
	nombre_original_ejercito = nuevo_nombre 
	_actualizar_botones_mazos()
	_exito_guardado()
