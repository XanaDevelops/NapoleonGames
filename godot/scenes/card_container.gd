class_name cardContainer
extends VBoxContainer

@export var card_name:Label
@export var hp_label:Label
@export var mana_label:Label
@export var portrait:TextureRect
@export var actor:Label
func paint(unit: UnitGame) -> void:
	self.card_name.text = unit._cardRes.name
	self.hp_label.text = "%d/%d" % [unit._tile.get_currentHealth(), unit.max_hp]
	self.mana_label.text = "%d/%d" % [unit._tile.get_currentMana(), unit.max_mana]  # ← mana_label
	self.portrait.texture= unit._cardRes.portrait
	self.actor.text= "objetivo"
	
