extends Control

@onready var mensaje_label = $MensajeVictoria


var nombre_ganador: String = ""

func _ready():
		mensaje_label.text = nombre_ganador + " ha ganado"
	
