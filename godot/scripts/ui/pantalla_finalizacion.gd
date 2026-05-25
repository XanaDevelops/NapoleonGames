extends Control

@onready var mensaje_label = $MensajeVictoria

var nombre_ganador: String = ""

func _ready() -> void:
	
	if nombre_ganador != "":
		mensaje_label.text = nombre_ganador + " ha ganado"
	else:
		mensaje_label.text = "¡Fin de la partida!"
		
	modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
