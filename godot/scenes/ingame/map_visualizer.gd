extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManagerNode.get_map() # Con esto tienes acceso al mapa, y por ende a las casillas, etc


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
