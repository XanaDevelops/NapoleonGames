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

## TODO estados alterados y toda la pesca
var has_moved_this_turn : bool = false
var has_hability_this_turn := false

func _init(cardRes: CardRes) -> void:
	self._cardRes = cardRes
	
	self.hp = cardRes.hp
	self.mana = cardRes.mana
	
	for h in self._cardRes.habilities:
		self._habilities.set(h, 0)
		
	

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
		GameManager.get_turn_manager()._on_unit_hability_use(null, null, hab)
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
		
	if hab.condition != HabilityRes.CONDITION.NA:
		pass
		
	# calcular valor final
	
	# por cada objetivo
	# aplicar el valor final
	#  si ataque recieve_attack
	#  si cura se puede hacer directo
	#  lanzar estados alterados
		
	
	# Las pasivas no gastan una habilidad
	if not hab.isPassive:
		has_hability_this_turn = true
		
	_habilities[hab] = hab.cooldown
	return true	

	
## funcion que calcula el daño recibido
## true si la mata
func recieve_attack(damage: int, type: AttackType) -> bool:
	push_warning("HOLA")
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
	pass

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
			
		## TODO comprobar si aplica
		
		ret.append(key)

	return ret
func get_texture2D() -> Texture2D:
	return self._cardRes.portrait
	
func get_speed() -> int:
	## TODO modificadores de velocidad!
	return self._cardRes.speed
