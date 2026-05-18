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
var game_config: GameConfig
var map_game: MapGame

func advance_turn() -> void:
	turn_number += 1
	var user : UserGame = turn_order[turn_number % turn_order.size()]
	print("Turno de ", user.get_user_res().username)
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

func get_map() -> MapGame:
	return map_game

func set_map(new_map: MapGame) -> void:
	map_game = new_map

func get_game_config() -> GameConfig:
	return game_config

func get_game_resources() -> GameResources:
	return GameManager.game_res

func get_app_state() -> GameManager.APP_STATE:
	return GameManager.app_state

func set_app_state(state: GameManager.APP_STATE) -> void:
	GameManager.app_state = state

func get_user_a() -> UserRes:
	return game_config.user_a

func get_user_b() -> UserRes:
	return game_config.user_b

func get_army_a() -> ArmyRes:
	return game_config.army_a

func get_army_b() -> ArmyRes:
	return game_config.army_b
	
	
func register_turn(turn: TurnAction) -> bool:
	
	turns.append(turn)
	return true

func replay_turn(turn: TurnAction) -> bool:
	match turn.action:
		TurnAction.ACTION.DEPLOYMENT:
			_replay_deployment(turn)
		TurnAction.ACTION.MOVEMENT:
			pass
		TurnAction.ACTION.ACTIVE, TurnAction.ACTION.PASSIVE:
			pass
		TurnAction.ACTION.PASS_TURN:
			# quizas comprobar esto sea correcto?
			advance_turn()
		_:
			push_error("[TurnManager] Accion no implementada ", turn.action)
			return false
			
			
	return true

func _get_UserGame_(uid: int) -> UserGame:
	if get_user_a().uid == uid:
		return turn_order[0]
	elif get_user_b().uid == uid:
		return turn_order[1]
	return null
	

## Reproduce un Deploy, principalmente del server, por lo deberia correcto
func _replay_deployment(turn: TurnDeploy) -> bool:
	var user_game := _get_UserGame_(turn.player_uid)
	if not user_game:
		return false
	var card_army_i := user_game.deployment_data.find_custom(func (x: CardArmyGroup):
		return x.cardType.uid == turn.unit_uid and x.n == turn.n)
	var card_army := user_game.deployment_data[card_army_i]
	
	return _on_deploy_group(user_game, card_army, turn.deploy_pos)

func _replay_movement(turn: TurnMove) -> bool:
	
	# TODO: realizar más comprobaciones?
	return _on_unit_movement_requested(turn.start_pos, turn.end_pos)
	
func _replay_hability(turn: TurnHability) -> bool:
	# TODO: más comprobaciones?
	var hab : HabilityRes = GameManager.get_game_resources().get_res_from_uid(turn.hability_uid, HabilityRes)
	return _on_unit_hability_use(turn.pos, turn.dest, hab)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.register_turn_manager(self)
	game_config = GameManager.get_game_config()
	if map_game == null and game_config and game_config.map_res:
		map_game = MapGame.new(game_config.map_res)
	if turn_order.is_empty() :
		if game_config == null:
			push_error("[TurnManager] Falta GameConfig para inicializar turn_order")
		else:
			turn_order = [UserGame.new(get_user_a()), UserGame.new(get_user_b())]

	if turn_order.size() >= 2:
		if turn_order[0].deployment_data.is_empty():
			turn_order[0].set_deployment_data(_clone_army(get_army_a()))
		if turn_order[1].deployment_data.is_empty():
			turn_order[1].set_deployment_data(_clone_army(get_army_b()))

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

func _on_unit_movement_requested(start: Vector2i, end: Vector2i) -> bool:
	var map_logic = get_map()
	var unit = map_logic.get_tile_at(start).get_unit()
	if unit.has_moved_this_turn:
		print("La unidad ya se ha movido")
		return false
		
	if unit._owner == get_current_user():
	
		map_logic.move_unit(start, end)
		unit.has_moved_this_turn = true
		map_visualizer.plot_unit_moved(start, end)
		
		var action := TurnMove.create(unit, start, end)
		register_turn(action)
	else:
		print("Acción denegada: No es el turno del dueño de esta unidad")
		return false
		
	return true

func _on_unit_hability_use(tile: Vector2i, objectives: Array[Vector2i], hability: HabilityRes) -> bool:
	var map : MapGame = get_map()
	var unit_source := map.get_tile_at(tile).get_unit()
	if unit_source.has_used_hability_this_turn:
		print("La unidad ya ha usado una habilidad activa!")
		return false
		
	if unit_source._owner != get_current_user():
		print("Acción denegada: No es el turno del dueño de esta unidad")
		return false
		
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
		return false
		
	var action := TurnHability.create(unit_source, tile, hability, objectives)
	register_turn(action)
		
	return true

func start_deployment_phase() -> void:
	is_deployment_phase = true
	players_panel.set_phase_deployment()
	cards_panel.set_deployment_phase(true)
	_refresh_ui_for_current_player()
	_highlight_current_deployment_zone()

func end_deployment_phase() -> void:
	is_deployment_phase = false
	set_app_state(GameManager.APP_STATE.IN_GAME)
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

	var result: Dictionary = map_game.calculate_deployment(get_current_user_number(), group.n, click_pos)
	if not result["is_valid"]:
		return false

	user_game.add_living_units(group.n)

	for pos in result["tiles"]:
		var new_unit := UnitGame.new(group.cardType, user_game)
		new_unit._owner = user_game

		map_game.place_unit(new_unit, pos)
		map_visualizer.draw_tile(pos.x, pos.y, map_game.get_tile_at(pos))

		new_unit.died.connect(_on_unit_died)
		
	var action := TurnDeploy.create(user_game, click_pos, group.cardType, group.n)
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
	var zone_tiles:Array[Vector2i] = map_game.get_deployment_zone_tiles(get_current_user_number())
	map_visualizer.show_deployment_zone(zone_tiles)


#esta función se ejecuta caundo una unidad emite que ha muerto
func _on_unit_died(unit: UnitGame, pos: Vector2i) -> void:
	map_visualizer.remove_unit(pos, map_game.get_tile_at(pos))

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
