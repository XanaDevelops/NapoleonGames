class_name PlayersPanel
extends Control


#PLAYER 1
@onready var p1_avatar: TextureRect = $HBoxContainer/PlayerCardP1/AvatarP1
@onready var p1_name: Label = $HBoxContainer/PlayerCardP1/NameP1
@onready var p1_card: HBoxContainer = $HBoxContainer/PlayerCardP1
@onready var p1_num_cards:Label= $HBoxContainer/PlayerCardP1/NumCardsP1
#PLAYER 2
@onready var p2_avatar: TextureRect = $HBoxContainer/PlayerCardP2/AvatarP2
@onready var p2_name: Label = $HBoxContainer/PlayerCardP2/NameP2
@onready var p2_card: HBoxContainer = $HBoxContainer/PlayerCardP2
@onready var p2_num_cards:Label = $HBoxContainer/PlayerCardP2/NumCardsP2
#PHASE
@onready var phase_label: Label = $HBoxContainer/CenterInfo/Phase
@onready var btn_end_turn: Button = $HBoxContainer/CenterInfo/EndTurn

var turnManager:TurnManager
var  total_cards_p1:int
var  total_cards_p2:int
var _p1: UserRes
var _p2: UserRes
var phase

#
func set_phase_battle() -> void:
	phase_label.text= "COMBATE"
	self.btn_end_turn.visible= false
	self.btn_end_turn.pressed.connect(pass_turn)
	self.turnManager.tick_turn.connect(update_turn_info)
	#p1_num_cards.visible= false
	#p2_num_cards.visible= false
	p1_num_cards.text= ""
	p2_num_cards.text= ""
	
	

func _ready() -> void:
	pass  

func setup(tm: TurnManager) -> void:
	turnManager = tm
	_p1 = tm.turn_order[0]
	_p2 = tm.turn_order[1]
	
	p1_name.text = _p1.username
	p1_avatar.texture = _p1.img
	p2_name.text = _p2.username
	p2_avatar.texture = _p2.img

func set_phase_deployment() -> void:
	phase_label.text = "Fase de DESPLIEGUE"
	btn_end_turn.visible = false
	
	total_cards_p1 = turnManager.get_player_cards(_p1)
	total_cards_p2 = turnManager.get_player_cards(_p2)
	
	p1_num_cards.text = "Cards 0/%d" % total_cards_p1
	p2_num_cards.text = "Cards 0/%d" % total_cards_p2
	p1_num_cards.visible = true
	p2_num_cards.visible = true
	
	if not turnManager.card_deployed.is_connected(update_cards_number):
		turnManager.card_deployed.connect(update_cards_number)
	#añadir más info..


func update_cards_number(player: UserRes, remaining_cards: int) -> void:
	if player == _p1:
		var placed = total_cards_p1 - remaining_cards
		p1_num_cards.text = "Cards %d/%d" % [placed, total_cards_p1]
	elif player == _p2:
		var placed = total_cards_p2 - remaining_cards
		p2_num_cards.text = "Cards %d/%d" % [placed, total_cards_p2]
		
func update_turn_info() -> void:
	phase_label.text = "FASE DE COMBATE\n Turno %d" %  turnManager.turn_number
	self.set_active_player()

func set_active_player() -> void:
	var is_p1:bool= turnManager.is_player1_turn()
	p1_card.modulate = Color.WHITE if is_p1 else Color(0.5, 0.5, 0.5)
	p2_card.modulate = Color(0.5, 0.5, 0.5) if is_p1 else Color.WHITE
	btn_end_turn.visible = true

func pass_turn() -> void:
	turnManager.advance_turn()
