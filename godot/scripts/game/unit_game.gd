class_name UnitGame
extends RuntimeResource

@export var _cardRes: CardRes

@export var _owner: UserRes
@export var _tile: TileGame
## Vida actual, si <=0 estas muerto
@export var hp: int

var max_hp : int :
	get : return _cardRes.hp
	set(x) : pass
	
var speed : int :
	get : return get_speed()
	set(x) : pass
	
var height : int :
	get : return _tile.get_height()
	set(x) : pass

## Manà actual
@export var mana: int

## estados alterados en activo con su duración restante
@export var _currentAlterStates: Dictionary[AlterStateRes, int] = {}
## habilidades disponibles con su tiempo de espera (0 se puede usar)
@export var _habilities: Dictionary[HabilityRes, int] = {}

signal health_changed(current: int)
signal mana_changed(current: int)

var _currentHealth: int:
	set(val):
		_currentHealth = val
		health_changed.emit(_currentHealth)

var _currentMana: int:
	set(val):
		_currentMana = val
		mana_changed.emit(_currentMana)

## TODO estados alterados y toda la pesca
var has_moved_this_turn : bool = false
var has_hability_this_turn := false

func _init(cardRes: CardRes, owner: UserRes) -> void:
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
## se debe llamar cada turno del jugador
func advance_turn() -> void:
	_tick()
	
	has_moved_this_turn = false
	has_hability_this_turn = false	
	
	_proc_passives()
	
## Usa una habilidad
## Devuelve si se ha usado correctamente
func use_hability(hab: HabilityRes, dest: Array[UnitGame]) -> bool:
	if hab not in get_available_habilities():
		printerr("Habilidad no disponible")
		return false
		
	## TODO: acabar condiciones
	if hab.condition != HabilityRes.CONDITION.NA:
		pass
		
	if self.mana < hab.manaCost:
		return false
		
	# calcular valor final
	var valor_final := hab.value
	# Por cada estado alterado que pueda afectar a la habilidad
	for alter : AlterStateRes in self._currentAlterStates:
		# Si afecta a la misma estadistica
		if alter.stat.name == hab.stat.name:
			# Si es ataque asegurarse que afecta al mismo tipo de ataque
			if alter.stat.name == StatData.ATTACK and (alter.type != hab.attackType):
				continue
			if alter.stat.isPercent:
				valor_final *= alter.value
			else:
				valor_final += alter.value
	# por cada objetivo
	for obj: UnitGame in dest:
		# aplicar el valor final
		match hab.stat.name:
			StatData.ATTACK:
				print("atacando por ", valor_final)
				obj.recieve_attack(valor_final, hab.attackType)
			StatData.HEALTH:
				obj.heal(valor_final, hab.stat)
			# Estadisticas que no se pueden modificar con una habilidad
			StatData.HEIGHT, StatData.MAX_HEALTH, StatData.MAX_MANA:
				push_error("Esto no se puede modificar con una habilidad!!")
			_:
				print("afectando por defecto ", hab.stat.name, " por valor de ", valor_final)
				obj.set(hab.stat.name, obj.get(hab.stat.name) + valor_final)
		
		#  lanzar estados alterados
		for alter in hab.alter_states:
			obj.add_alter_state(alter)
	
	# Las pasivas no gastan una habilidad
	if not hab.isPassive:
		has_hability_this_turn = true
		
	_habilities[hab] = hab.cooldown
	return true	

	
## funcion que calcula el daño recibido
## true si la mata
func recieve_attack(damage: int, type: AttackType) -> bool:
	# Calcular defensa base a ese tipo
	var defense: int
	if self._cardRes.resistances.has(type):
		defense = self._cardRes.resistances.get(type)
	else:
		push_warning("No se ha configurado valor de defensa para " + type.name + ", se asume 0")
		defense = 0
	
	# Comprobar si algun estado alterado altera ese valor
	for state in self._currentAlterStates:
		if !HabilityRes.inflicts_self(state.objectiu):
			continue
			
		# ojo que randf() es [0,1] no [0,1)
		if randf() > state.hitP:
			continue
		
		## FIXME no me acaba de gustar esto
		if state.stat.name != StatData.DEFENSE:
			continue
		if state.type != type:
			continue
		if state.stat.isPercent:
			defense *= state.value
		else:
			defense += state.value
			
	## PLACEHOLDER!
	var inflict_damage := maxi(0, damage-defense)
	print("inflicted_damage: " + str(inflict_damage))
	self.hp -= inflict_damage
	return self.hp <= 0
	
## mata a la unidad
func kill() -> void:
	pass

func heal(value: int, type: StatData) -> void:
	if value < 0:
		print("Curando por un valor negativo?? ", value)
	if type.isPercent:
		self.hp += self.max_hp * value
	else:
		self.hp += value
		
	self.hp = mini(self.hp, self.max_hp)

func add_alter_state(alter: AlterStateRes) -> void:
	self._currentAlterStates.set(alter, alter.duration)

## devuelve la casilla donde se encuentra
func _get_height() -> int:
	return _tile.get_height()
	
## Devuelve las habilidades que se pueden usar
func get_available_habilities() -> Array[HabilityRes]:
	var ret : Array[HabilityRes] = []
	for key in self._habilities:
		var cd := _habilities[key]
		if cd > 0:
			continue
		var condition_ok = true
		if key.condition != HabilityRes.CONDITION.NA and key.condition_stat != null:
			var unit= _tile.get_unit()
			var current_value = key._get_stat_value(unit, key.condition_stat)
			condition_ok = key.applies(current_value)
			var is_available = key.isPassive or key.manaCost>unit._currentMana or not condition_ok
			if is_available:
				ret.append(key)
				
		## TODO comprobar si aplica
		

	return ret

## Devuelve todas las habilidades de la carta referencia
func get_all_habilities() -> Array[HabilityRes]:
	return _cardRes.habilities
	
func get_texture2D() -> Texture2D:
	return self._cardRes.img
	
func get_speed() -> int:
	## TODO modificadores de velocidad!
	return self._cardRes.speed
	
## Obtiene de la referencia al _tile la posicion de este
## Util para llamar pasivas
func get_current_position() -> Vector2i:
	return _tile.get_position()
