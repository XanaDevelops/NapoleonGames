extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.match_mode == GameManager.MATCHMAKING_MODE.JvJ:
		text = "Iniciar Partida"
	else:
		text = "Buscar Partida"
