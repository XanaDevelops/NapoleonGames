extends Control

@export var hability_name:Label
@export var cooldown_value:Label
@export var cost_mana:Label
@export var rang:Label
@export var card1:cardContainer
@export var target_cards_container:HBoxContainer
@export var title:Label

@export var mana_effect_container: HBoxContainer
@export var mana_effect: Label

@export var health_effect_container: HBoxContainer
@export var health_effect: Label



@export var effect_states_label: Label

signal confirmed
signal cancelled
func paint(hability:HabilityRes, unit:UnitGame, targets:Array[Vector2i])-> void:
	for child in target_cards_container.get_children():
		child.queue_free()
	self.title.text= "usar habilidad"
	self.hability_name.text= hability.name
	self.cooldown_value.text= str(hability.cooldown)
	self.rang.text= str(hability.radius)
	self.cost_mana.text= str(hability.manaCost)
	card1.paint(unit, "atacante")
	var map_game= GameManager.get_turn_manager().get_map()
	_paint_generic_effects(hability)
	for target in targets:
		var unit_target= map_game.get_tile_at(target).get_unit()
		if unit_target == null:
			continue
		var card = preload("res://scenes/card_container.tscn").instantiate()
		target_cards_container.add_child(card)
		card.paint(unit_target, "objetivo")
		
	
	
func _paint_generic_effects(hab: HabilityRes) -> void:
	# Ocultar todos primero
	mana_effect_container.visible = false
	health_effect_container.visible = false



	# Efecto principal según stat
	if hab.stat != null:
		var sign = "+" if hab.stat.name==StatData.HEALTH else "-"
		var value_text: String
		if hab.stat.isPercent:
			value_text = "%s%d%%" % [sign, int(hab.value * 100)]
		else:
			value_text = "%s%d" % [sign, int(hab.value)]

		match hab.stat.name:
			StatData.ATTACK:
				health_effect_container.visible = true
				health_effect.text = value_text
			StatData.HEALTH:
				health_effect_container.visible = true
				health_effect.text = value_text


	

func _on_confirmed_pressed() -> void:
	confirmed.emit()
	


func _on_canceled_pressed() -> void:
	cancelled.emit()
