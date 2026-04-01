class_name UnitGame
extends Node

@export var _cardRes: CardRes

@export var _owner: UserRes

## Vida actual, si <=0 estas muerto
@export var _currentHealth: int
## Manà actual
@export var _currentMana: int

## estados alterados en activo con su duración restante
@export var _currentAlterStates: Dictionary[AlterStateRes, int] = {}
## habilidades disponibles con su tiempo de espera (0 se puede usar)
@export var _habilities: Dictionary[HabilityRes, int] = {}

## TODO estados alterados y toda la pesca

func _init(cardRes: CardRes) -> void:
	self._cardRes = cardRes
	
	self._currentHealth = cardRes.hp
	self._currentMana = cardRes.mana
	
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

## se debe llamar cada turno
## TODO preguntar si cooldowns bajan por turno (global) o turno (jugador)
func advance_turn() -> void:
	_tick()
	
	
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
		self._currentHealth -= maxi(0, damage-defense)
	return self._currentHealth <= 0
	
## mata a la unidad
func kill() -> void:
	pass
## devuelve la casilla donde se encuentra
func _get_tile() -> TileGame:
	return null
	
func get_texture2D() -> Texture2D:
	return self._card_res.img
	
