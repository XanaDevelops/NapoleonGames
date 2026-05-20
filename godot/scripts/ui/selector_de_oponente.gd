extends Control

@onready var contenedor_lista_oponentes: VBoxContainer = %Oponentes
@onready var boton_jugar: Button = %IniciarPartida

@onready var contenedor_pestanas_mazos: HBoxContainer = %PestanasMazos
@onready var contenedor_cartas: GridContainer = %ContenedorCartas

@export_group("Temas y Estilos")
@export var tema_pestana_activa: Theme
@export var tema_pestana_inactiva: Theme
@export var tema_jugador_seleccionado: Theme
@export var tema_jugador_no_seleccionado: Theme

@export_group("Escenas")
@export var escena_carta_ui: PackedScene

var oponente_seleccionado: UserRes = null
var mapa_seleccionado: MapRes = null 
var ejercito_oponente_seleccionado: ArmyRes = null

var boton_actualmente_resaltado: Button = null
var boton_pestana_activa: Button = null

func _ready() -> void:
	if boton_jugar:
		boton_jugar.disabled = true
		boton_jugar.pressed.connect(ir_a_siguiente)

	if UserManager.has_signal("usuarios_actualizados"):
		UserManager.usuarios_actualizados.connect(cargar_lista_de_oponentes)

	cargar_lista_de_oponentes()

func cargar_lista_de_oponentes() -> void:
	for nodo_hijo in contenedor_lista_oponentes.get_children():
		nodo_hijo.queue_free()
		
	var cantidad_de_usuarios_validos = 0
	var primer_jugador: UserRes = null
	var primer_boton: Button = null
		
	for correo_electronico in UserManager.usuarios:
		var jugador_evaluado: UserRes = UserManager.usuarios[correo_electronico]
		
		if jugador_evaluado == UserManager.usuario_actual:
			continue 
			
		var boton_jugador = Button.new()
		var nombre := jugador_evaluado.name
		
		if nombre == "":
			nombre = str(jugador_evaluado.username)

		boton_jugador.text = nombre + "\n" + jugador_evaluado.email
		boton_jugador.custom_minimum_size = Vector2(260, 55)	
			
		if tema_jugador_no_seleccionado:
			boton_jugador.theme = tema_jugador_no_seleccionado
		
	
		boton_jugador.pressed.connect(func(): seleccionar_oponente(jugador_evaluado, boton_jugador))
		
		
		boton_jugador.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
				
				seleccionar_oponente(jugador_evaluado, boton_jugador)
	
				ir_a_siguiente()
		)
		
		contenedor_lista_oponentes.add_child(boton_jugador)
		
		if cantidad_de_usuarios_validos == 0:
			primer_jugador = jugador_evaluado
			primer_boton = boton_jugador
		
		cantidad_de_usuarios_validos += 1

	if cantidad_de_usuarios_validos == 0:
		var etiqueta_sin_usuarios = Label.new()
		etiqueta_sin_usuarios.text = "No hay usuarios para seleccionar"
		etiqueta_sin_usuarios.add_theme_color_override("font_color", Color(1, 0, 0)) 
		etiqueta_sin_usuarios.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
		etiqueta_sin_usuarios.autowrap_mode = TextServer.AUTOWRAP_WORD 
		contenedor_lista_oponentes.add_child(etiqueta_sin_usuarios)
	else:
		if primer_jugador and primer_boton:
			seleccionar_oponente(primer_jugador, primer_boton)

func seleccionar_oponente(usuario_elegido: UserRes, boton_presionado: Button) -> void:
	oponente_seleccionado = usuario_elegido
	
	if boton_actualmente_resaltado != null and is_instance_valid(boton_actualmente_resaltado):
		if tema_jugador_no_seleccionado:
			boton_actualmente_resaltado.theme = tema_jugador_no_seleccionado
		else:
			boton_actualmente_resaltado.modulate = Color(1, 1, 1)

	boton_actualmente_resaltado = boton_presionado
	
	if tema_jugador_seleccionado:
		boton_actualmente_resaltado.theme = tema_jugador_seleccionado
	else:
		boton_actualmente_resaltado.modulate = Color.GREEN 
	
	if boton_jugar:
		boton_jugar.disabled = false 
		
	cargar_mazos_de_oponente(usuario_elegido)

func cargar_mazos_de_oponente(oponente: UserRes) -> void:
	for hijo in contenedor_pestanas_mazos.get_children():
		hijo.queue_free()
	for hijo in contenedor_cartas.get_children():
		hijo.queue_free()
		
	boton_pestana_activa = null
	ejercito_oponente_seleccionado = null
	
	var mazos = oponente.userArmys
	
	if mazos.is_empty():
		if boton_jugar:
			boton_jugar.disabled = true
	
		var etiqueta := Label.new()
		etiqueta.text = "Este oponente no tiene ejércitos disponibles"
		contenedor_cartas.add_child(etiqueta)
	return
		
	for mazo in mazos:
		var boton_pestana = Button.new()
		boton_pestana.text = mazo.nom
		
		if tema_pestana_inactiva:
			boton_pestana.theme = tema_pestana_inactiva
			
		boton_pestana.pressed.connect(func(): seleccionar_mazo(mazo, boton_pestana))
		contenedor_pestanas_mazos.add_child(boton_pestana)
		
		if mazo.isActive and ejercito_oponente_seleccionado == null:
			seleccionar_mazo(mazo, boton_pestana)
			
	if ejercito_oponente_seleccionado == null and contenedor_pestanas_mazos.get_child_count() > 0:
		seleccionar_mazo(mazos[0], contenedor_pestanas_mazos.get_child(0) as Button)

func seleccionar_mazo(mazo_elegido: ArmyRes, boton_presionado: Button) -> void:
	ejercito_oponente_seleccionado = mazo_elegido
	
	if boton_pestana_activa != null and is_instance_valid(boton_pestana_activa):
		if tema_pestana_inactiva:
			boton_pestana_activa.theme = tema_pestana_inactiva
			
	boton_pestana_activa = boton_presionado
	
	if tema_pestana_activa:
		boton_pestana_activa.theme = tema_pestana_activa
		
	mostrar_cartas_del_mazo(mazo_elegido)

func mostrar_cartas_del_mazo(mazo: ArmyRes) -> void:
	for hijo in contenedor_cartas.get_children():
		hijo.queue_free()
		
	if escena_carta_ui == null:
		push_error("Error: no se ha asignado la escena_carta_ui en el inspector.")
		return
		
	for agrupacion in mazo.agrupations:
		var carta_instancia = escena_carta_ui.instantiate() as CardUI
		if carta_instancia:
			contenedor_cartas.add_child(carta_instancia)
			carta_instancia.configurar(agrupacion.cardType, agrupacion.n, true)

func ir_a_siguiente() -> void:
	if oponente_seleccionado == null:
		push_warning("No hay oponente seleccionado")
		return

	if ejercito_oponente_seleccionado == null:
		push_warning("El oponente no tiene ejército seleccionado")
		return

	UiManager.cambiar_a_escena("resumen", {
		"mapa_seleccionado": mapa_seleccionado,
		"oponente_seleccionado": oponente_seleccionado,
		"ejercito_oponente_seleccionado": ejercito_oponente_seleccionado
	})
