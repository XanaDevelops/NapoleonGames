class_name UnitGame
extends RuntimeResource

## Maná por turno
const PASSIVE_MANA := 5

signal hit_received(type: AttackType)
signal dodged() 
signal healed()

@export var _cardRes: CardRes

@export var _owner: UserGame
@export var _tile: TileGame
## Vida actual, si <=0 estas muerto
@export var hp: int:
	set(val):
		hp = clampi(val, 0, max_hp)
		health_changed.emit(hp)

var max_hp : int :
	get : return _cardRes.hp
	set(x) : pass
	
var speed : int :
	get : return await get_speed()
	set(x) : pass
	
var height : int :
	get : return _tile.get_height()
	set(x) : pass
	
var dodge : float :
	get : return await _update_val_alter_states(_cardRes.dodge, StatData.DODGE)

## Manà actual
@export var mana: int:
	set(val):
		mana = clampi(val, 0, max_mana)
		mana_changed.emit(mana)

## Maná maximo
var max_mana: int :
	get() : return self._cardRes.mana
	
## estados alterados en activo con su duración restante
@export var _currentAlterStates: Dictionary[AlterStateRes, int] = {}
## habilidades disponibles con su tiempo de espera (0 se puede usar)
@export var _habilities: Dictionary[HabilityRes, int] = {}

signal health_changed(current: int)
signal mana_changed(current: int)
signal died(unit: UnitGame, pos: Vector2i)
var has_moved_this_turn : bool = false
var has_used_hability_this_turn := false

func _init(cardRes: CardRes, owner: UserGame) -> void:
	self._cardRes = cardRes
	
	self.hp = cardRes.hp
	self.mana = cardRes.mana
	
	for h in self._cardRes.habilities:
		self._habilities.set(h, 0)
		
	self._owner = owner
	
## Avanza los contadores de habilidades y estados alterados
func _tick() -> void:
	for key in self._currentAlterStates.keys():
		var cd : int = self._currentAlterStates.get(key)
		cd-=1
		if cd <= 0:
			self._currentAlterStates.erase(key)
		else:
			self._currentAlterStates.set(key, cd)
			
	for key in self._habilities.keys():
		var cd: int = self._habilities.get(key)
		cd -= 1
		self._habilities.set(key, maxi(0, cd))
		
## Lanzar pasivas
func _proc_passives() -> void:
	for hab in get_available_habilities():
		if not hab.isPassive:
			continue
		# LLamar a turn manager
		GameManager.get_turn_manager()._on_unit_hability_use(_tile.get_position(), [], hab)

## Activa los estados alterados como los de daño o cura
func _proc_alter_states() -> void:
	for alter in self._currentAlterStates:
		if await NetClient.request_randf_server() > alter.hitP:
			print("[" + str(NetClient.id) + "] ", "Evitado estado alterado ", alter.uid)
			continue
			
		# Reutilizar esta funcion, un AlterState no deja de ser una minihabilidad
		var tm := GameManager.get_turn_manager()
		var map := tm.get_map()
		var dest : Array[UnitGame] = []
		if HabilityRes.inflicts_strict_self(alter.objective):
			dest.append(self)
		elif map:
			dest.append_array(map.get_units_range(_tile.get_position(), alter.radius, alter.objective) \
					.map(func (x: Vector2i): return map.get_tile_at(x).get_unit()) as Array[UnitGame])
		for obj in dest:
			_apply_hab(alter.stat, alter.type, alter.value, obj)
		

## se debe llamar cada turno del jugador
## Se debe vincular con TurnManager
func advance_turn() -> void:
	var tm := GameManager.get_turn_manager()
	if tm == null:
		return
	# Si es despliegue ignoramos esta llamadas
	if tm.get_app_state() != GameManager.APP_STATE.IN_GAME:
		return
 	# Por UI mover esto aquñi
	has_moved_this_turn = false

	if tm.get_current_user() != _owner:
		return
	
	_tick()
	
	has_used_hability_this_turn = false	
	
	# maná pasivo
	self.mana += PASSIVE_MANA
	
	_proc_passives()
	_proc_alter_states()
	
## Usa una habilidad
## Devuelve si se ha usado correctamente
func use_hability(hab: HabilityRes, dest: Array[UnitGame]) -> bool:
	var _available := get_available_habilities()
	## FIXME: Evitar uso 
	if not _available.any(func (x:HabilityRes): return hab.compare(x)):
		printerr("[" + str(NetClient.id) + "]", "Habilidad no disponible")
		printerr("[" + str(NetClient.id) + "]", "hab: ", hab.uid, ":", hab.name, " not in ", _available.map(func (x: HabilityRes): return x.uid))
		return false
	
	self.mana-=hab.manaCost
	# Tecnicamente es codigo duplicado de get_avaliable_habilities
		
	# calcular valor final
	var valor_final := await _update_val_alter_states(hab.value, hab.stat.name, hab.attackType)
	# por cada objetivo
	for obj: UnitGame in dest:
		_apply_hab(hab.stat, hab.attackType, valor_final, obj)
		
		#  lanzar estados alterados
		for alter in hab.alter_states:
			obj.add_alter_state(alter)
	
	# Las pasivas no gastan una habilidad
	if not hab.isPassive:
		has_used_hability_this_turn = true
		
	_habilities[hab] = hab.cooldown
	
	return true	

## Aplica el valor a una estadistica a un objetivo
func _apply_hab(stat: StatData, atkType:AttackType, val:float, obj: UnitGame):
	# aplicar el valor final
	match stat.name:
		StatData.ATTACK:
			print("[" + str(NetClient.id) + "]", "atacando por ", val)
			#Ha muerto la unidad
			if await obj.recieve_attack(val, atkType):
				obj.kill()
		StatData.HEALTH:
			obj.heal(val, stat)
			# Ponder en algun lado si curar mata
			if obj.hp == 0:
				obj.kill()
		# Estadisticas que no se pueden modificar con una habilidad
		StatData.HEIGHT, StatData.MAX_HEALTH, StatData.MAX_MANA:
			push_error("Esto no se puede modificar con una habilidad!!")
			printerr("En el caso de MAX_HEALTH o MAX_MANA, hazlo con HP con isPercent=True, respectivamente")
		_:
			print("[" + str(NetClient.id) + "]", "afectando por defecto ", stat.name, " por valor de ", val)
			obj.set(stat.name, obj.get(stat.name) + val)
	
## funcion que calcula el daño recibido
## true si la mata
func recieve_attack(damage: int, type: AttackType) -> bool:
	# Calcular esquive
	
	# ojo que randf() es [0,1] no [0,1)
	if await NetClient.request_randf_server() < self.dodge:
		print("[" + str(NetClient.id) + "]", "esquive! ", self.dodge)
		dodged.emit()
		return false
	
	
	# Calcular defensa base a ese tipo
	var defense: int
	if self._cardRes.resistances.has(type):
		defense = self._cardRes.resistances.get(type)
	else:
		print_rich("[" + str(NetClient.id) + "]", "[color=yellow]No se ha configurado valor de defensa para " + type.name + ", se asume 0[/color]")
		defense = 0
	
	defense = await _update_val_alter_states(defense, StatData.DEFENSE, type)
			
	## PLACEHOLDER!
	var inflict_damage := maxi(0, damage-defense)
	print("[" + str(NetClient.id) + "]", "inflicted_damage: " + str(inflict_damage) + " with defense " + str(defense))
	self.hp -= inflict_damage
	
	hit_received.emit(type)

		
	return self.hp <= 0
## mata a la unidad
func kill() -> void:
	var tm := GameManager.get_turn_manager()
	if tm != null and tm.tick_turn.is_connected(self.advance_turn):
			tm.tick_turn.disconnect(self.advance_turn)
			#GameManager.get_map().get_tile_at(_tile._position).set_unit(null)
			#notificar al turn_manager
	if not _tile:
		push_error("no hay tile")
	else:
		_tile.set_unit(null)
		died.emit(self, _tile._position)
		
	_tile = null 

## Cura una unidad
func heal(value: int, type: StatData) -> void:
	if value < 0:
		print_rich("[" + str(NetClient.id) + "]", "[color=yellow]Curando por un valor negativo[/color] ", value)
		
	value = await _update_val_alter_states(value, StatData.HEALTH)
	if type.isPercent:
		self.hp += self.max_hp * value
	else:
		self.hp += value
	
	healed.emit()


func add_alter_state(alter: AlterStateRes) -> void:
	self._currentAlterStates.set(alter, alter.duration)

## devuelve la casilla donde se encuentra
func _get_height() -> int:
	return _tile.get_height()
	
## Devuelve las habilidades (activas y pasivas) que se pueden usar
## Las pasivas no deberian ser lanzadas por el jugador
func get_available_habilities() -> Array[HabilityRes]:
	var ret : Array[HabilityRes] = []
	for key in self._habilities:
		var cd := _habilities[key]
		if cd > 0:
			continue
			
		var tm := GameManager.get_turn_manager()
		var map := tm.get_map()
		if map == null:
			continue
		if map.get_units_range(_tile.get_position(), key.radius, key.objective).size() == 0:
			continue
		
		if key.manaCost > self.mana:
			continue
		if key.condition != HabilityRes.CONDITION.NA and key.condition_stat != null:
			var current_value :float = get(key.condition_stat.name)
			if key.condition_stat.isPercent:
				# Asumimos que queremos comparar con un valor max de la estadistica
				assert(key.condition_stat.name.contains("max_"))
				current_value = get(key.condition_stat.name.trim_prefix("max_")) / current_value
			if key.applies(current_value):
				ret.append(key)
		else:
			ret.append(key)

	return ret

## Devuelve todas las habilidades de la carta referencia
func get_all_habilities() -> Array[HabilityRes]:
	return _cardRes.habilities
	
func get_texture2D() -> Texture2D:
	return self._cardRes.img
	
func get_speed() -> int:
	var base_speed := self._cardRes.speed
	
	return await _update_val_alter_states(base_speed, StatData.SPEED)
	
## Obtiene de la referencia al _tile la posicion de este
## Util para llamar pasivas
func get_current_position() -> Vector2i:
	return _tile.get_position()
	
## Actualiza un valor acorde a los estados alterados vigentes
## Notese que solo cuentan estados alterados que afecten a la unidad
## *IMPORTANTE* esto **SÍ** aplica la probabilidad de acierto de un estado alterado, calcular una unica vez por uso
func _update_val_alter_states(init_val : float, stat_name:StringName, type: AttackType = null) -> float:
	var final_val := init_val
	
	var multipliers := 1.0
	
	for alter in self._currentAlterStates:
		if not HabilityRes.inflicts_self(alter.objective):
			continue

		if alter.stat.name != stat_name:
			continue
		if type and alter.type != type:
			continue

		# ojo que randf() es [0,1] no [0,1)
		if await NetClient.request_randf_server() > alter.hitP:
			print("[" + str(NetClient.id) + "]","Esquiva estado alterado al calcular stat ", stat_name)
			continue
			
		
			
		if alter.stat.isPercent:
			multipliers += alter.value
		else:
			final_val += alter.value
	
	return final_val * multipliers
	
## Devuelve si tiene acciones pendientes
## Una habilidad debe de tener objetivos validos para tenerlo en cuenta
## Mirar de comprobar si tiene movimientos disponibles
func has_pending_actions() -> bool:
	return (not has_moved_this_turn) or ((get_available_habilities().any(func (x: HabilityRes): 
			return not x.isPassive)) and (not has_used_hability_this_turn)) 

	
