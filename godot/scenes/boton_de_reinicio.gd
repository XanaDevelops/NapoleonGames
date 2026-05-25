extends Button


func _ready() -> void:
	
	pressed.connect(_al_pulsar)

func _al_pulsar() -> void:
	GameManager.restart_current_game()
