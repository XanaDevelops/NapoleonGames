class_name TurnManager
extends Node


signal card_deployed(player: UserGame, remaining: int)
signal deployment_phase_started(first_player_name: String)
signal combat_phase_started(first_player_name: String)
signal turn_changed_visual(current_icon: Texture2D, next_name: String, next_icon: Texture2D)

signal tick_turn
signal game_end

# Algunas señales tienen pinta de ser de ui->ui, revisar
signal ui_setup_requested(turn_manager: TurnManager)
signal deployment_phase_started
signal battle_phase_started
signal deployment_data_refreshed(groups: Array)
signal deployment_card_consumed(group: CardArmyGroup)
signal unit_moved(start: Vector2i, end: Vector2i)
signal tile_draw_requested(pos: Vector2i, tile: TileGame)
signal deployment_zone_updated(tiles: Array[Vector2i])
signal deployment_zone_cleared
signal deployment_preview_cleared
signal unit_removed(pos: Vector2i, tile: TileGame)
signal movement_enabled
signal unit_info_cleared

@export var turns: Array[TurnAction] = []
var turn_order: Array[UserGame] = []
var turn_number: int = 0
var global_action_count: int = 0
var is_deployment_phase: bool = false
var game_config: GameConfig
var map_game: MapGame

## true si se esta reproduciendo un turno.
## por lo que no hay que enviarlo al server de nuevo, ni esperar confirmación
var replaying_turn = false

func advance_turn(skip_visual: bool = false) -> void:
	var user := get_current_user()
	if not is_deployment_phase:
		register_turn(TurnPass.create(user, _get_game_pid()))
	turn_number += 1
	var next_user : UserGame = turn_order[turn_number % turn_order.size()]
	print("[" + str(NetClient.id) + "]", "Turno de ", next_user.get_user_res().username)
	tick_turn.emit()
	
	if not skip_visual:
		var prev_res = user.get_user_res()
		var next_res = next_user.get_user_res()
		turn_changed_visual.emit(prev_res.img, next_res.name, next_res.img)
	
	
	
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

func _get_game_pid() -> int:
	return game_config.game_pid if game_config else -1

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
	if game_config.game_pid != -1 and not GameManager.is_server and not replaying_turn:
		print("[" + str(NetClient.id) + "]", "comprobación en server")
		turn.send(Online.server_peer)
		var res : bool = await NetClient.server_turn_response
		if not res:
			print("[" + str(NetClient.id) + "]", "TURNO INVALIDADO POR SERVER")
			return false
		
			
	print("[" + str(NetClient.id) + "]", "registered " + var_to_str(turn.action))
	turn.action_order = global_action_count
	global_action_count += 1
	turns.append(turn)
	return true

func replay_turn(turn: TurnAction) -> bool:
	replaying_turn = true
	var ok := false
	match turn.action:
		TurnAction.ACTION.DEPLOYMENT:
			ok = await _replay_deployment(turn)
		TurnAction.ACTION.MOVEMENT:
			ok = await _replay_movement(turn)
		TurnAction.ACTION.ACTIVE, TurnAction.ACTION.PASSIVE:
			ok = await _replay_hability(turn)
		TurnAction.ACTION.PASS_TURN:
			# quizas comprobar esto sea correcto?
			advance_turn()
			## FIXME:
			ok = true
			
		_:
			push_error("[TurnManager] Accion no implementada ", turn.action)
			ok =  false
			
	replaying_turn = false
	return ok

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
		print("[" + str(NetClient.id) + "]", "UserName null")
		return false
	var card_army_i := user_game.deployment_data.find_custom(func (x: CardArmyGroup):
		return x.cardType.uid == turn.unit_uid and x.n == turn.n)
	var card_army := user_game.deployment_data[card_army_i]
	
	return await _on_deploy_group(user_game, card_army, turn.deploy_pos)

func _replay_movement(turn: TurnMove) -> bool:
	
	# TODO: realizar más comprobaciones?
	return await _on_unit_movement_requested(turn.start_pos, turn.end_pos)
	
func _replay_hability(turn: TurnHability) -> bool:
	# TODO: más comprobaciones?
	var hab : HabilityRes = GameManager.get_game_resources().get_res_from_uid(turn.hability_uid, HabilityRes)
	# FIXME: las pasivas se autolanzan, por ende repetir la pasiva fallará (seguramente)
	if hab.isPassive:
		return true
	return await _on_unit_hability_use(turn.pos, turn.dest, hab)

func _init() -> void:
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_inside_tree():
		await get_tree().process_frame

	ui_setup_requested.emit(self)
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
		print("[" + str(NetClient.id) + "]", "La unidad ya se ha movido")
		return false
		
	if unit._owner == get_current_user():
		var action := TurnMove.create(unit, start, end, _get_game_pid())
		if not await register_turn(action):
			print("[" + str(NetClient.id) + "]", "Movimiento denegada al registrar")
			return false
		
		map_logic.move_unit(start, end)
		unit.has_moved_this_turn = true
		unit_moved.emit(start, end)
		
		
	else:
		print("[" + str(NetClient.id) + "]", "Acción denegada: No es el turno del dueño de esta unidad")
		return false
		
	return true


func _on_unit_hability_use(tile: Vector2i, objectives: Array[Vector2i], hability: HabilityRes) -> bool:
	var map : MapGame = get_map()
	var unit_source := map.get_tile_at(tile).get_unit()
	if unit_source.has_used_hability_this_turn:
		print("[" + str(NetClient.id) + "]", "La unidad ya ha usado una habilidad activa!")
		return false
		
	if unit_source._owner != get_current_user():
		print("[" + str(NetClient.id) + "]", "Acción denegada: No es el turno del dueño de esta unidad")
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

	var action := TurnHability.create(unit_source, tile, hability, objectives, _get_game_pid())
	if not await register_turn(action):
		print("[" + str(NetClient.id) + "]", "Habilidad denegada por server")
		return false
	
	var res := await unit_source.use_hability(hability, _dest)
	if not res:
		print("[" + str(NetClient.id) + "]", "No se cumple las condiciones para usar esta habilidad!")
		return false
		
	
		
	return true

func start_deployment_phase() -> void:
	is_deployment_phase = true
	deployment_phase_started.emit()
	_refresh_ui_for_current_player()
	_highlight_current_deployment_zone()
	var current_user = get_current_user()
	
	deployment_phase_started.emit(current_user.get_user_res().name)
	
func end_deployment_phase() -> void:
	is_deployment_phase = false
	battle_phase_started.emit()
	movement_enabled.emit()
	deployment_zone_cleared.emit()
	deployment_preview_cleared.emit()
		
	var current_user = get_current_user()
	combat_phase_started.emit(current_user.get_user_res().username) # FIXME: señal duplicada con battle_phase_started.emit()
	
func _on_deploy_group(user_game: UserGame, group: CardArmyGroup, click_pos: Vector2i) -> bool:
	if not is_deployment_phase:
		print("[" + str(NetClient.id) + "]", "no es deploy")
		return false
	if user_game != get_current_user():
		print("[" + str(NetClient.id) + "]", "no es el usuario activo")
		return false
	if group == null:
		print("[" + str(NetClient.id) + "]", "no hay grupo")
		return false
	if not user_game.deployment_data.has(group):
		print("[" + str(NetClient.id) + "]", "el grpo no pertece al user")
		return false

	var result: Dictionary = map_game.calculate_deployment(get_current_user_number(), group.n, click_pos)
	if not result["is_valid"]:
		print("[" + str(NetClient.id) + "]", "zona despliegue no valida")
		return false

	var action := TurnDeploy.create(user_game, click_pos, group.cardType, group.n, _get_game_pid())
	if not await register_turn(action):
		print("[" + str(NetClient.id) + "]", "Despliegue denegado por server")
		return false

	user_game.add_living_units(group.n)

	for pos in result["tiles"]:
		var new_unit := UnitGame.new(group.cardType, user_game)
		new_unit._owner = user_game

		map_game.place_unit(new_unit, pos)
		tile_draw_requested.emit(pos, map_game.get_tile_at(pos))

		new_unit.died.connect(_on_unit_died)
		
	

	deployment_preview_cleared.emit()

	_consume_current_card(user_game, group)
	return true

func _consume_current_card(user_game: UserGame, group: CardArmyGroup) -> void:
	if user_game.consume_deployment_group(group):
		deployment_card_consumed.emit(group)
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
		advance_turn(true)
		end_deployment_phase()
		



func _refresh_ui_for_current_player() -> void:
	var user := get_current_user()
	deployment_data_refreshed.emit(user.deployment_data)

func _has_cards_to_deploy(user: UserGame) -> bool:
	return user.has_deployment_cards()

func _highlight_current_deployment_zone() -> void:
	var zone_tiles:Array[Vector2i] = map_game.get_deployment_zone_tiles(get_current_user_number())
	deployment_zone_updated.emit(zone_tiles)


#esta función se ejecuta caundo una unidad emite que ha muerto
func _on_unit_died(unit: UnitGame, pos: Vector2i) -> void:
	unit_removed.emit(pos, map_game.get_tile_at(pos))

	if tick_turn.is_connected(unit.advance_turn):
			tick_turn.disconnect(unit.advance_turn)
	
	unit_info_cleared.emit()

	unit._owner.dec_living_units(1)
	print("[" + str(NetClient.id) + "]", unit._owner.get_user_res().name + " ha perdido una unidad. Le quedan: ", unit._owner.living_units)
		
		# Si llega a 0, la partida termina inmediatamente
	if unit._owner.living_units <= 0:
			
		var ganador = turn_order[0] if unit._owner == turn_order[1] else turn_order[1]
			
		print("[" + str(NetClient.id) + "]", "¡Partida terminada! El ganador es: ", ganador.get_user_res().name)
		finalizar_partida(ganador.get_user_res().name)

func finalizar_partida(nombre_del_vencedor: String):
	
	var parametros_victoria = {
		"nombre_ganador": nombre_del_vencedor
	}
	
	game_end.emit()
	UiManager.cambiar_a_escena("finalizacion", parametros_victoria)
