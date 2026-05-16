extends Control

@onready var titulo_panel: Label = $Panel/TituloPanel
@onready var rich_text_label: RichTextLabel = $Panel/Panel/Panel/MarginContainer/RichTextLabel
@onready var boton_volver: Button = $Panel/Vover
@onready var boton_iniciar: Button = $Panel/IniciarPartida


var mapa_seleccionado: MapRes = null
var oponente_seleccionado: UserRes = null
var ejercito_oponente_seleccionado: ArmyRes = null

func _ready() -> void:
	boton_iniciar.pressed.connect(_on_iniciar_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)
	
	_mostrar_resumen_partida()

func _mostrar_resumen_partida() -> void:
	if rich_text_label == null:
		return
		
	var jugador_uno = UserManager.usuario_actual
	var jugador_dos = oponente_seleccionado
	
	var mazo_uno = jugador_uno.obtener_ejercito_activo()
	var mazo_dos = ejercito_oponente_seleccionado
	if mazo_dos == null and jugador_dos != null:
		mazo_dos = jugador_dos.obtener_ejercito_activo()
		
	var mapa_nombre = mapa_seleccionado.name if mapa_seleccionado and "name" in mapa_seleccionado else "No seleccionado"
	if mapa_seleccionado and "nom" in mapa_seleccionado and mapa_nombre == "No seleccionado":
		mapa_nombre = mapa_seleccionado.get("nom")

	
	
	var texto = "[center]" # Abrimos el centrado de todo el texto

	texto += "[b]MAPA DEL ENCUENTRO:[/b]\n"
	texto += "" + str(mapa_nombre) + "\n\n"

	texto += "[color=GREEN][b]JUGADOR 1 (TÚ):[/b][/color]\n"
	texto += "Nombre: " + str(jugador_uno.name) + "\n"
	texto += "Mazo: " + (str(mazo_uno.nom) if mazo_uno else "Ninguno") + "\n\n"

	texto += "[color=RED][b]JUGADOR 2 (RIVAL):[/b][/color]\n"	
	texto += "Nombre: " + (str(jugador_dos.name) if jugador_dos else "Desconocido") + "\n"
	texto += "Mazo: " + (str(mazo_dos.nom) if mazo_dos else "Ninguno") + "\n"

	texto += "[/center]" # Cerramos el centrado al final
	
	rich_text_label.bbcode_enabled = true
	rich_text_label.text = texto

func _on_iniciar_pressed() -> void:
	var jugador_uno = UserManager.usuario_actual
	var mazo_uno = jugador_uno.obtener_ejercito_activo()
	
	var mazo_dos = ejercito_oponente_seleccionado
	if mazo_dos == null and oponente_seleccionado != null:
		mazo_dos = oponente_seleccionado.obtener_ejercito_activo()
		
	
	GameManager.start_game(jugador_uno, oponente_seleccionado, mapa_seleccionado, mazo_uno, mazo_dos)

func _on_volver_pressed() -> void:

	UiManager.cambiar_a_escena("oponente", {
		"mapa_seleccionado": mapa_seleccionado
	})
