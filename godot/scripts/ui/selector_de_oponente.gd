extends Control

@onready var contenedor_lista_oponentes: VBoxContainer = $PanelDeOponente/ScrollContainer/Oponentes
@onready var boton_jugar: Button = $IniciarPartida

var oponente_seleccionado: UserRes = null
var mapa_seleccionado: MapRes = null 
var boton_actualmente_resaltado: Button = null

func _ready() -> void:
	if boton_jugar:
		boton_jugar.disabled = true
		boton_jugar.pressed.connect(iniciar_partida)
	
	cargar_lista_de_oponentes()

func cargar_lista_de_oponentes() -> void:
	for nodo_hijo in contenedor_lista_oponentes.get_children():
		nodo_hijo.queue_free()
		
	var cantidad_de_usuarios_validos = 0
		
	for correo_electronico in UserManager.usuarios:
		var jugador_evaluado: UserRes = UserManager.usuarios[correo_electronico]
		
		if jugador_evaluado == UserManager.usuario_actual:
			continue 
			
		var boton_jugador = Button.new()
		boton_jugador.text = jugador_evaluado.name
		
		# Ah
		boton_jugador.pressed.connect(func(): seleccionar_oponente(jugador_evaluado, boton_jugador))
		
		contenedor_lista_oponentes.add_child(boton_jugador)
		
		cantidad_de_usuarios_validos += 1

	if cantidad_de_usuarios_validos == 0:
		var etiqueta_sin_usuarios = Label.new()
		etiqueta_sin_usuarios.text = "No hay usuarios para seleccionar"
		etiqueta_sin_usuarios.add_theme_color_override("font_color", Color(1, 0, 0)) 
		etiqueta_sin_usuarios.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
		etiqueta_sin_usuarios.autowrap_mode = TextServer.AUTOWRAP_WORD 
		contenedor_lista_oponentes.add_child(etiqueta_sin_usuarios)

func seleccionar_oponente(usuario_elegido: UserRes, boton_presionado: Button) -> void:
	oponente_seleccionado = usuario_elegido
	

	if boton_actualmente_resaltado != null:
		boton_actualmente_resaltado.modulate = Color(1, 1, 1)
		

	boton_actualmente_resaltado = boton_presionado
	boton_actualmente_resaltado.modulate = Color.GREEN 
	
	if boton_jugar:
		boton_jugar.disabled = false 

func iniciar_partida() -> void:
	var jugador_uno = UserManager.usuario_actual
	var jugador_dos = oponente_seleccionado
	
	var ejercito_jugador_uno = jugador_uno.obtener_ejercito_activo()
	var ejercito_jugador_dos = jugador_dos.obtener_ejercito_activo()
	
	GameManagerNode.start_game(jugador_uno, jugador_dos, mapa_seleccionado, ejercito_jugador_uno, ejercito_jugador_dos)
