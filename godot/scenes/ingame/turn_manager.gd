class_name TurnManager
extends Node


signal card_deployed(player: UserRes, remaining: int)
## Los UnitGame deben subscribirse a esto para avanzar el turno
signal tick_turn

@onready var cards_panel = $IngameMap/VBoxContainer/CardsPanel
@onready var deployment_box = $IngameMap/VBoxContainer/CardsPanel/MarginContainer/DeploymentBox
@onready var map_visualizer = $IngameMap/VBoxContainer/PanelContainer/SubViewportContainer/SubViewport/mapVisualizer
@onready var players_panel= $IngameMap/VBoxContainer/PlayersPanel
@export var turns: Array[TurnAction] = []
var turn_order: Array[UserRes] = []
var turn_number: int = 0

var player_deployment_data: Dictionary[UserRes, Array] = {}
var living_units: Dictionary[UserRes, int] = {}
var pending_deployment_group: CardArmyGroup = null
var is_deployment_phase: bool = false


class TurnAction extends GameResource:
	enum ACTION {
		MOVEMENT, #movimiento
		ACTIVE,   #uso de habilidad activa
		PASSIVE,   #activación de habilidad pasiva
		DEPLOYMENT
	}
	var player: UserRes
	var action : ACTION
	var unit : UnitGame
	var start : Vector2i
	var end : Vector2i
	var hability : HabilityRes
	var dest : Array[Vector2i]
	var deploy_pos : Vector2i
	
	func _init() -> void:
		pass
		
			

func advance_turn() -> void:
	var user : UserRes = turn_order[turn_number % turn_order.size()]
	print("Turno de ", user.username)
	turn_number += 1
	tick_turn.emit()
	map_visualizer._clear_selection()
	
	
func get_current_user() -> UserRes:
	return turn_order[turn_number % turn_order.size()]
	
func get_current_user_number() -> int:
	return turn_number % turn_order.size()

func is_player1_turn() -> bool:
	return self.get_current_user()==turn_order[0]
## Placeholder para 

func get_player_cards(player:UserRes) -> int:
	if player_deployment_data.has(player):
		return player_deployment_data[player].size()
	return 0
func register_turn(turn: TurnAction) -> bool:
	
	turns.append(turn)
	return true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.turn_manager = self 
	deployment_box.unit_selected_for_deployment.connect(_on_card_selected_in_ui)
	map_visualizer.tile_clicked.connect(_on_hex_clicked)
	if turn_order.is_empty() :
		turn_order = [GameManager._user_a, GameManager._user_b]
	
	if player_deployment_data.is_empty():
		## FIXME: usar .deep_duplicate
		player_deployment_data[turn_order[0]] = _clone_army(GameManager._army_a)
		player_deployment_data[turn_order[1]] = _clone_army(GameManager._army_b)
	
	for usuario in turn_order:
		living_units[usuario] = 0
	players_panel.setup(self)
	start_deployment_phase()
	
	#end_deployment_phase()

func _clone_army(army: ArmyRes) -> Array[CardArmyGroup]:
	var copy: Array[CardArmyGroup] = []
	if army:
		for group in army.agrupations:
			copy.append(group.duplicate())
	return copy
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_unit_movement_requested(start: Vector2i, end: Vector2i) -> void:
	var map_logic = GameManager.get_map()
	var unit = map_logic.get_tile_at(start).get_unit()
	if unit.has_moved_this_turn:
		print("La unidad ya se ha movido")
		return
		
	if unit._owner == get_current_user():
	
		map_logic.move_unit(start, end)
		unit.has_moved_this_turn = true
		map_visualizer.plot_unit_moved(start, end)
		
		var action = TurnAction.new()
		action.player = unit._owner
		action.action = TurnAction.ACTION.MOVEMENT
		action.start = start
		action.end = end
		register_turn(action)
	else:
		print("Acción denegada: No es el turno del dueño de esta unidad")


func _on_unit_hability_use(tile: Vector2i, objectives: Array[Vector2i], hability: HabilityRes) -> void:
	var map : MapGame = GameManager.get_map()
	var unit_source := map.get_tile_at(tile).get_unit()
	if unit_source.has_hability_this_turn:
		print("La unidad ya ha usado una habilidad activa!")
		return
		
	if unit_source._owner != get_current_user():
		print("Acción denegada: No es el turno del dueño de esta unidad")
		return
		
	var _dest : Array[UnitGame] = []
	
	# Si no se especifica objetivos, por ejemplo desde una llamada interna de pasiva
	# o por lo que sea, se obtiene todas las unidades a rango
	if not objectives or objectives.size() == 0:
		# Si no se especifica obtiene las unidades a rango
		objectives = map.get_units_range(tile, hability.radius, hability.objective)
		
	objectives.map(
		func (x: Vector2i): _dest.append(map.get_tile_at(x).get_unit())
	)

	
	var res := unit_source.use_hability(hability, _dest)
	if not res:
		print("No se cumple las condiciones para usar esta habilidad!")
		return
		
	var action := TurnAction.new()
	if hability.isPassive:
		action.action = TurnAction.ACTION.PASSIVE
	else:
		action.action = TurnAction.ACTION.ACTIVE
	action.action = TurnAction.ACTION.ACTIVE
	action.player = unit_source._owner
	action.unit = unit_source
	action.start = tile
	action.end = tile
	action.dest = objectives
	
	register_turn(action)
		

func start_deployment_phase() -> void:
	is_deployment_phase = true
	players_panel.set_phase_deployment()
	cards_panel.set_deployment_phase(true)
	_refresh_ui_for_current_player()
	_highlight_current_deployment_zone()
	
	if map_visualizer and not map_visualizer.tile_hovered.is_connected(_on_map_tile_hovered):
		map_visualizer.tile_hovered.connect(_on_map_tile_hovered)

func end_deployment_phase() -> void:
	is_deployment_phase = false
	players_panel.set_phase_battle()

	cards_panel.set_deployment_phase(false)
	map_visualizer.movement_requested.connect(_on_unit_movement_requested)
	#GameManager._app_state= GameManager.APP_STATE.IN_GAME
	
	if map_visualizer:
		map_visualizer.clear_deployment_zone()
		map_visualizer.clear_deployment_preview()
		
		if map_visualizer.tile_hovered.is_connected(_on_map_tile_hovered):
			map_visualizer.tile_hovered.disconnect(_on_map_tile_hovered)

func _on_hex_clicked(click_pos: Vector2i, _tile: TileGame = null) -> void:
	if pending_deployment_group == null:
		return
		
	var current_user := get_current_user()
	var result:Dictionary = GameManager._gameMap.calculate_deployment(get_current_user_number(), pending_deployment_group.n, click_pos)
	
	if not result["is_valid"]:
		return
	
	living_units[current_user] +=pending_deployment_group.n 
	
	for pos in result["tiles"]:
		var new_unit := UnitGame.new(pending_deployment_group.cardType, get_current_user())
		new_unit._owner = current_user
		
		GameManager._gameMap.place_unit(new_unit, pos)
		map_visualizer.draw_tile(pos.x, pos.y, GameManager._gameMap.get_tile_at(pos))
		
		new_unit.died.connect(_on_unit_died)
		var action := TurnAction.new()
		action.player = current_user
		action.action = TurnAction.ACTION.DEPLOYMENT
		action.unit = new_unit
		action.deploy_pos = pos
		register_turn(action)
		
	if map_visualizer:
		map_visualizer.clear_deployment_preview()
		
	_consume_current_card()

func _consume_current_card() -> void:
	var current_user := get_current_user()
	if player_deployment_data.has(current_user):
		player_deployment_data[current_user].erase(pending_deployment_group)
		deployment_box.remove_card_visual(pending_deployment_group)
		card_deployed.emit(current_user, player_deployment_data[current_user].size())

	
	pending_deployment_group = null

	_handle_next_deployment_step()

func _handle_next_deployment_step() -> void:
	var current_idx := get_current_user_number()
	var opponent_idx := (current_idx + 1) % 2
	
	var current_user := get_current_user()
	var opponent_user := turn_order[opponent_idx]
	
	if _has_cards_to_deploy(opponent_user):
		advance_turn()
		_refresh_ui_for_current_player()
		_highlight_current_deployment_zone()
	elif _has_cards_to_deploy(current_user):
		pass # Opponent is out of cards, current user continues
	else:
		end_deployment_phase()
		advance_turn()



func _refresh_ui_for_current_player() -> void:
	var user := get_current_user()
	
	if player_deployment_data.has(user):
		
		deployment_box.populate(player_deployment_data[user])

func _has_cards_to_deploy(user: UserRes) -> bool:
	return player_deployment_data.has(user) and not player_deployment_data[user].is_empty()

func _on_card_selected_in_ui(army_group: CardArmyGroup) -> void:
	pending_deployment_group = army_group

func _highlight_current_deployment_zone() -> void:
	var zone_tiles:Array[Vector2i] = GameManager._gameMap.get_deployment_zone_tiles(get_current_user_number())
	map_visualizer.show_deployment_zone(zone_tiles)

func _on_map_tile_hovered(coords: Vector2i) -> void:
	if pending_deployment_group == null:
		if map_visualizer: 
			map_visualizer.clear_deployment_preview()
		return
		
	var result:Dictionary= GameManager._gameMap.calculate_deployment(get_current_user_number(), pending_deployment_group.n, coords)
	map_visualizer.show_deployment_preview(result["tiles"], result["is_valid"])


#esta función se ejecuta caundo una unidad emite que ha muerto
func _on_unit_died(unit: UnitGame, pos: Vector2i) -> void:
	map_visualizer.remove_unit(pos, GameManager._gameMap.get_tile_at(pos))

	if tick_turn.is_connected(unit.advance_turn):
			tick_turn.disconnect(unit.advance_turn)
	
	cards_panel.clear_unit_info()
	
	living_units[unit._owner] -= 1
	print(unit._owner.name + " ha perdido una unidad. Le quedan: ", living_units[unit._owner])
		
		# Si llega a 0, la partida termina inmediatamente
	if living_units[unit._owner] <= 0:
			
		var ganador = turn_order[0] if unit._owner == turn_order[1] else turn_order[1]
			
		print("¡Partida terminada! El ganador es: ", ganador.name)
		finalizar_partida(ganador.name)

func finalizar_partida(nombre_del_vencedor: String):
	
	var parametros_victoria = {
		"nombre_ganador": nombre_del_vencedor
	}
	UiManager.cambiar_a_escena("finalizacion", parametros_victoria)
