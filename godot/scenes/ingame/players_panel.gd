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

func _ready() -> void:
	self.turnManager= GameManager.get_turn_manager()
	#setup()

func set_phase_deployment() -> void:
	self.btn_end_turn.visible= false
	self.turnManager.card_deployed.connect(update_cards_number)
	p1_num_cards.text = "Cards %d/%d" % [total_cards_p1, total_cards_p1]
	p2_num_cards.text = "Cards %d/%d" % [total_cards_p2, total_cards_p2]
	p1_num_cards.visible= true
	p2_num_cards.visible= true

func set_phase_battle() -> void:
	self.btn_end_turn.pressed.connect(pass_turn)
	self.turnManager.tick_turn.connect(update_turn_info)
	p1_num_cards.visible= false
	p2_num_cards.visible= false
	
	#añadir más info..
func setup() -> void:
	phase_label.text= "Fase de %s"%GameManager.get_current_phase()
	var p1:UserRes= GameManager._user_a
	var p2:UserRes= GameManager._user_b
	
	_p1 = p1
	_p2 = p2
	total_cards_p1 = turnManager.get_player_cards(p1)
	total_cards_p2 = turnManager.get_player_cards(p2)
	p1_name.text = p1.username
	p1_avatar.texture = p1.img
	p2_name.text = p2.username
	p2_avatar.texture = p2.img


func update_cards_number(player: UserRes, remaining_cards: int) -> void:
	if player == _p1:
		p1_num_cards.text = "Cards %d/%d" % [remaining_cards, total_cards_p1]
	elif player == _p2:
		p2_num_cards.text = "Cards %d/%d" % [remaining_cards, total_cards_p2]

func update_turn_info() -> void:
	phase_label.text = "%s - Turno %d" % [GameManager.get_current_phase(), turnManager.turn_number]
	self.set_active_player()

func set_active_player() -> void:
	var is_p1:bool= turnManager.is_player1_turn()
	p1_card.modulate = Color.WHITE if is_p1 else Color(0.5, 0.5, 0.5)
	p2_card.modulate = Color(0.5, 0.5, 0.5) if is_p1 else Color.WHITE
	btn_end_turn.visible = true

func pass_turn() -> void:
	turnManager.advance_turn()
