extends Control

@export var carta_ui: PackedScene 


@onready var contenedor_disponibles = %ContenedorCartasDisponibles
@onready var contenedor_mazo = %ContenedorMazo
@onready var label_peso = %LabelPeso
@onready var input_nombre_ejercito = %LineEditNombreEjercito

@onready var boton_guardar = %BotonGuardarEjercito
@onready var boton_nuevo = %BotonNuevo
@onready var boton_eliminar = %BotonEliminar
@onready var fila_botones_mazos = %FilaBotonesMazos

var ejercito_actual: ArmyRes
var nombre_original_ejercito: String = ""

var nodos_disponibles: Dictionary = {}
var nodos_mazo: Dictionary = {}        

func _ready() -> void:
	boton_guardar.pressed.connect(_pulsar_guardar)
	boton_nuevo.pressed.connect(_pulsar_nuevo)
	boton_eliminar.pressed.connect(_pulsar_eliminar)
	
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

func _actualizar_botones_mazos() -> void:
	for hijo in fila_botones_mazos.get_children():
		hijo.queue_free()
		
	var ejercitos = UserManager.obtener_ejercitos()
	
	for i in range(ejercitos.size()):
		var mazo = ejercitos[i]
		var nuevo_boton = Button.new()
		
		if mazo.isActive:
			nuevo_boton.text = "** "+ mazo.nom
		else:
			nuevo_boton.text = mazo.nom
			
		if ejercito_actual != null and mazo.nom == ejercito_actual.nom:
			nuevo_boton.modulate = Color(0.5, 1.0, 0.5) 
			
		nuevo_boton.pressed.connect(_seleccionar_ejercito.bind(i))
		fila_botones_mazos.add_child(nuevo_boton)

func _seleccionar_ejercito(indice: int) -> void:
	var ejercitos = UserManager.obtener_ejercitos()
	ejercito_actual = ejercitos[indice].clonar()
	nombre_original_ejercito = ejercito_actual.nom 
	
	UserManager.establecer_ejercito_activo(ejercito_actual.nom)
	_cargar_interfaz_inicial()

func _pulsar_nuevo() -> void:
	ejercito_actual = ArmyRes.new()
	ejercito_actual.nom = "Nuevo Ejército"
	ejercito_actual.isActive = true 
	nombre_original_ejercito = "Nuevo Ejército" 
	
	_cargar_interfaz_inicial()

func _pulsar_eliminar() -> void:
	UserManager.eliminar_ejercito(nombre_original_ejercito)
	
	var ejercitos = UserManager.obtener_ejercitos()
	if ejercitos.is_empty():
		_pulsar_nuevo()
	else:
		_seleccionar_ejercito(0)

func _pulsar_guardar() -> void:
	var nuevo_nombre = input_nombre_ejercito.text.strip_edges() 
	
	if nuevo_nombre.is_empty():
		print("Error: El nombre del ejército no puede estar vacío.")
		input_nombre_ejercito.text = nombre_original_ejercito 
		return
		
	if nuevo_nombre != nombre_original_ejercito and UserManager.existe_ejercito(nuevo_nombre):
		print("Error: Ya existe un ejército llamado así.")
		input_nombre_ejercito.text = nombre_original_ejercito 
		return
		
	ejercito_actual.nom = nuevo_nombre
	ejercito_actual.isActive = true
	
	UserManager.guardar_ejercito(ejercito_actual, nombre_original_ejercito)
	UserManager.establecer_ejercito_activo(nuevo_nombre)
	
	nombre_original_ejercito = nuevo_nombre 
	_actualizar_botones_mazos() 

func _limpiar_tablero() -> void:
	for nodo in nodos_mazo.keys():
		nodo.queue_free()
	nodos_mazo.clear()
	
	for nodo in nodos_disponibles.values():
		nodo.queue_free()
	nodos_disponibles.clear()

func _cargar_interfaz_inicial() -> void:
	_limpiar_tablero() 
	input_nombre_ejercito.text = ejercito_actual.nom
	
	for grupo in ejercito_actual.agrupations:
		_instanciar_carta_mazo(grupo)
		
	_actualizar_cartas_libres_visuales()
	_actualizar_texto_peso()
	_actualizar_botones_mazos()

func _doble_click_inventario(nodo_carta: CardUI) -> void:
	var carta_pulsada = nodo_carta.mi_carta_res
	if ejercito_actual.get_weight() + carta_pulsada.weight > ArmyRes.MAX_SIZE:
		print("¡Límite de peso superado!")
		return
		
	var nuevo_grupo = CardArmyGroup.new()
	nuevo_grupo.cardType = carta_pulsada 
	nuevo_grupo.n = 1                    
	ejercito_actual.agrupations.append(nuevo_grupo)
	
	_instanciar_carta_mazo(nuevo_grupo)
	_actualizar_cartas_libres_visuales()
	_actualizar_texto_peso()

func _click_izquierdo_mazo(nodo_carta: CardUI) -> void:
	var grupo = nodos_mazo[nodo_carta] as CardArmyGroup
	var carta_res = grupo.cardType
	var restantes = _calcular_cartas_libres().get(carta_res, 0)
	
	if restantes > 0 and (ejercito_actual.get_weight() + carta_res.weight <= ArmyRes.MAX_SIZE):
		grupo.n += 1 
		nodo_carta.actualizar_cantidad(grupo.n)
		_actualizar_cartas_libres_visuales()
		_actualizar_texto_peso()
	else:
		print("No te quedan más cartas o límite de peso lleno.")

func _click_derecho_mazo(nodo_carta: CardUI) -> void:
	var grupo = nodos_mazo[nodo_carta] as CardArmyGroup
	grupo.n -= 1 
	
	if grupo.n <= 0:
		ejercito_actual.agrupations.erase(grupo)
		nodos_mazo.erase(nodo_carta)
		nodo_carta.queue_free()
	else:
		nodo_carta.actualizar_cantidad(grupo.n)
		
	_actualizar_cartas_libres_visuales()
	_actualizar_texto_peso()

func _instanciar_carta_mazo(grupo: CardArmyGroup) -> void:
	var nueva_carta = carta_ui.instantiate() as CardUI
	contenedor_mazo.add_child(nueva_carta)
	nueva_carta.configurar(grupo.cardType, grupo.n) 
	nueva_carta.click_simple.connect(_click_izquierdo_mazo)
	nueva_carta.click_derecho.connect(_click_derecho_mazo)
	nodos_mazo[nueva_carta] = grupo

func _actualizar_cartas_libres_visuales() -> void:
	var cartas_restantes = _calcular_cartas_libres()
	
	for carta in cartas_restantes.keys():
		var cantidad = cartas_restantes[carta]
		if nodos_disponibles.has(carta):
			var nodo = nodos_disponibles[carta]
			if cantidad <= 0:
				nodo.queue_free()
				nodos_disponibles.erase(carta)
			else:
				nodo.actualizar_cantidad(cantidad)
		elif cantidad > 0:
			var nueva_carta = carta_ui.instantiate() as CardUI
			contenedor_disponibles.add_child(nueva_carta)
			nueva_carta.configurar(carta, cantidad)
			nueva_carta.doble_click.connect(_doble_click_inventario)
			nodos_disponibles[carta] = nueva_carta

func _calcular_cartas_libres() -> Dictionary:
	var inventario = UserManager.usuario_actual.availableCards.duplicate()
	for grupo in ejercito_actual.agrupations:
		if inventario.has(grupo.cardType): 
			inventario[grupo.cardType] -= grupo.n 
	return inventario

func _actualizar_texto_peso() -> void:
	label_peso.text = "Peso: " + str(ejercito_actual.get_weight()) + " / " + str(ArmyRes.MAX_SIZE)
