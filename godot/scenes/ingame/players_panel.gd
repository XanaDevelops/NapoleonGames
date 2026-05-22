class_name PlayersPanel
extends Control


#PLAYER 1
@export var p1_avatar: TextureRect 
@export var p1_name: Label 
@export var p1_card: HBoxContainer 
@export var p1_num_cards:Label
#PLAYER 2
@export var p2_avatar: TextureRect 
@export var p2_name: Label 
@export var p2_card: HBoxContainer 
@export var p2_num_cards:Label 

#PHASE
@export var phase_label: Label 
@export var TurnLabel:Label
var turnManager:TurnManager
var  total_cards_p1:int
var  total_cards_p2:int
var _p1: UserGame
var _p2: UserGame
var phase

#
func set_phase_battle() -> void:
	phase_label.text= "FASE DE COMBATE"
	

	self.turnManager.tick_turn.connect(update_turn_info)

	p1_num_cards.text= ""
	p2_num_cards.text= ""
	
	

func _ready() -> void:
	pass  

func setup(tm: TurnManager) -> void:
	turnManager = tm
	_p1 = tm.turn_order[0]
	_p2 = tm.turn_order[1]
	
	var p1_res := _p1.get_user_res()
	var p2_res := _p2.get_user_res()
	p1_name.text = p1_res.username
	p1_avatar.texture = p1_res.img
	p2_name.text = p2_res.username
	p2_avatar.texture = p2_res.img

func set_phase_deployment() -> void:
	phase_label.text = "FASE DE DESPLIEGUE"
	
	total_cards_p1 = turnManager.get_player_cards(_p1)
	total_cards_p2 = turnManager.get_player_cards(_p2)
	
	p1_num_cards.text = "Cards 0/%d" % total_cards_p1
	p2_num_cards.text = "Cards 0/%d" % total_cards_p2
	p1_num_cards.visible = true
	p2_num_cards.visible = true
	
	if not turnManager.card_deployed.is_connected(update_cards_number):
		turnManager.card_deployed.connect(update_cards_number)


func update_cards_number(player: UserGame, remaining_cards: int) -> void:
	if player == _p1:
		var placed = total_cards_p1 - remaining_cards
		p1_num_cards.text = "Cards %d/%d" % [placed, total_cards_p1]
	elif player == _p2:
		var placed = total_cards_p2 - remaining_cards
		p2_num_cards.text = "Cards %d/%d" % [placed, total_cards_p2]
		
func update_turn_info() -> void:
	TurnLabel.text= "TURNO %d" %turnManager.turn_number
	self.set_active_player()

func set_active_player() -> void:
	var is_p1:bool= turnManager.is_player1_turn()
	p1_card.modulate = Color.WHITE if is_p1 else Color(0.5, 0.5, 0.5)
	p2_card.modulate = Color(0.5, 0.5, 0.5) if is_p1 else Color.WHITE
