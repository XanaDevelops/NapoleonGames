class_name UnitGame
extends Node

@export var _cardRes: CardRes

@export var currentHealth: int

## TODO estados alterados y toda la pesca

func _init(cardRes: CardRes) -> void:
	self._cardRes = cardRes
	
	self.currentHealth = cardRes.hp
	
func get_texture2D() -> Texture2D:
	return self._card_res.img
