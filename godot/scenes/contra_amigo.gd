extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	GameManager.match_mode = GameManager.MATCHMAKING_MODE.NET_FRIEND
	UiManager.cambiar_a_escena("mapas")
