class_name TurnManager
extends Node


signal card_deployed(player: UserGame, remaining: int)
## Los UnitGame deben subscribirse a esto para avanzar el turno
signal tick_turn

@onready var cards_panel = $IngameMap/VBoxContainer/CardsPanel
@onready var deployment_box = $IngameMap/VBoxContainer/CardsPanel/MarginContainer/DeploymentBox
@onready var map_visualizer = $IngameMap/VBoxContainer/PanelContainer/SubViewportContainer/SubViewport/mapVisualizer
@onready var players_panel= $IngameMap/VBoxContainer/PlayersPanel
@export var turns: Array[TurnAction] = []
var turn_order: Array[UserGame] = []
var turn_number: int = 0
var is_deployment_phase: bool = false

func advance_turn() -> void:
	var user : UserGame = turn_order[turn_number % turn_order.size()]
	print("Turno de ", user.get_user_res().username)
	turn_number += 1
	tick_turn.emit()
	
	
func get_current_user() -> UserGame:
	return turn_order[turn_number % turn_order.size()]
	
func get_current_user_number() -> int:
	return turn_number % turn_order.size()

func get_current_phase() -> String:
	if is_deployment_phase:
		return "Despliegue"
	return "Combate"

func is_player1_turn() -> bool:
	return self.get_current_user()==turn_order[0]
## Placeholder para 

func get_player_cards(player: UserGame) -> int:
	return player.get_deployment_count()
	
	
func register_turn(turn: TurnAction) -> bool:
	
	turns.append(turn)
	return true

func replay_turn(turn: TurnAction) -> bool:
	match turn.action:
		TurnAction.ACTION.DEPLOYMENT:
			pass
		TurnAction.ACTION.MOVEMENT:
			pass
		TurnAction.ACTION.ACTIVE, TurnAction.ACTION.PASSIVE:
			pass
		_:
			push_error("[TurnManager] Accion desconocida ", turn.action)
			return false
			
			
	return true
		


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.turn_manager = self 
	if turn_order.is_empty() :
		turn_order = [UserGame.new(GameManager._user_a), UserGame.new(GameManager._user_b)]

	if turn_order.size() >= 2:
		if turn_order[0].deployment_data.is_empty():
			turn_order[0].set_deployment_data(_clone_army(GameManager._army_a))
		if turn_order[1].deployment_data.is_empty():
			turn_order[1].set_deployment_data(_clone_army(GameManager._army_b))

	for usuario in turn_order:
		usuario.living_units = 0
	players_panel.setup(self)
	start_deployment_phase()
	
	#end_deployment_phase()

func _clone_army(army: ArmyRes) -> Array[CardArmyGroup]:
	var copy: Array[CardArmyGroup] = []
	if army:
		for group in army.agrupations:
			copy.append(group.duplicate())
	return copy

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
	if unit_source.has_used_hability_this_turn:
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
	GameManager._app_state = GameManager.APP_STATE.DEPLOYMENT
	players_panel.set_phase_deployment()
	cards_panel.set_deployment_phase(true)
	_refresh_ui_for_current_player()
	_highlight_current_deployment_zone()

func end_deployment_phase() -> void:
	is_deployment_phase = false
	GameManager._app_state = GameManager.APP_STATE.IN_GAME
	players_panel.set_phase_battle()

	cards_panel.set_deployment_phase(false)
	map_visualizer.movement_requested.connect(_on_unit_movement_requested)
	
	if map_visualizer:
		map_visualizer.clear_deployment_zone()
		map_visualizer.clear_deployment_preview()

func _on_deploy_group(user_game: UserGame, group: CardArmyGroup, click_pos: Vector2i) -> bool:
	if not is_deployment_phase:
		return false
	if user_game != get_current_user():
		return false
	if group == null:
		return false
	if not user_game.deployment_data.has(group):
		return false

	var result: Dictionary = GameManager._gameMap.calculate_deployment(get_current_user_number(), group.n, click_pos)
	if not result["is_valid"]:
		return false

	user_game.add_living_units(group.n)

	for pos in result["tiles"]:
		var new_unit := UnitGame.new(group.cardType, user_game)
		new_unit._owner = user_game

		GameManager._gameMap.place_unit(new_unit, pos)
		map_visualizer.draw_tile(pos.x, pos.y, GameManager._gameMap.get_tile_at(pos))

		new_unit.died.connect(_on_unit_died)
		var action := TurnAction.new()
		action.player = user_game
		action.action = TurnAction.ACTION.DEPLOYMENT
		action.unit = new_unit
		action.deploy_pos = pos
		register_turn(action)

	if map_visualizer:
		map_visualizer.clear_deployment_preview()

	_consume_current_card(user_game, group)
	return true

func _consume_current_card(user_game: UserGame, group: CardArmyGroup) -> void:
	if user_game.consume_deployment_group(group):
		deployment_box.remove_card_visual(group)
		card_deployed.emit(user_game, user_game.get_deployment_count())

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
	deployment_box.populate(user.deployment_data)

func _has_cards_to_deploy(user: UserGame) -> bool:
	return user.has_deployment_cards()

func _highlight_current_deployment_zone() -> void:
	var zone_tiles:Array[Vector2i] = GameManager._gameMap.get_deployment_zone_tiles(get_current_user_number())
	map_visualizer.show_deployment_zone(zone_tiles)


#esta función se ejecuta caundo una unidad emite que ha muerto
func _on_unit_died(unit: UnitGame, pos: Vector2i) -> void:
	map_visualizer.remove_unit(pos, GameManager._gameMap.get_tile_at(pos))

	if tick_turn.is_connected(unit.advance_turn):
			tick_turn.disconnect(unit.advance_turn)
	
	cards_panel.clear_unit_info()

	unit._owner.dec_living_units(1)
	print(unit._owner.get_user_res().name + " ha perdido una unidad. Le quedan: ", unit._owner.living_units)
		
		# Si llega a 0, la partida termina inmediatamente
	if unit._owner.living_units <= 0:
			
		var ganador = turn_order[0] if unit._owner == turn_order[1] else turn_order[1]
			
		print("¡Partida terminada! El ganador es: ", ganador.get_user_res().name)
		finalizar_partida(ganador.get_user_res().name)

func finalizar_partida(nombre_del_vencedor: String):
	
	var parametros_victoria = {
		"nombre_ganador": nombre_del_vencedor
	}
	UiManager.cambiar_a_escena("finalizacion", parametros_victoria)
