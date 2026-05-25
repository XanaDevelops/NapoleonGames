
## Tipo de casilla ([TileTypeRes])[br]
##Define el tipo de casilla del mapa y sus modificadores.[br]
## [br]
##Atributos:[br]
## - name: Nombre del tipo de casilla.[br]
## - desc: Descripción del tipo de casilla.[br]
## - mods: Modificadores aplicados a la casilla (Array[[TileModRes]]).[br]
class_name TileTypeRes
extends GameResource

## Nombre del tipo de casilla (identificador)
@export var name: StringName
## Descripción del tipo de casilla
@export var desc: String
## Modificadores aplicados a la casilla (Array[[TileModRes]])
@export var mods: Array[TileModRes] = []
## Coste base de pasar por esta casilla
@export var cost := 1
## Textura de la casilla
@export var texture: Texture2D

## Dada una carta, el coste por pasar por esta casilla
func get_total_cost(card: CardRes) -> int:
	var _cost = cost
	for mod in mods:
		if mod.stat.name == StatData.SPEED and _check_match(card.types, mod.affectType):
			if mod.stat.isPercent:
				_cost *= mod.value
			else:
				_cost += mod.value
	return _cost
	
## Tiene en cuenta herencia
func _check_match(types: Array[CardTypeRes], mod: CardTypeRes) -> bool:
	## lambda recursiva, yay
	var _check_type := func (x: CardTypeRes, f : Callable) -> bool:
		if x.uid == mod.uid:
			return true
		if x.parentType:
			return f.call(x.parentType, f) as bool
		return false
	return types.any(func (x: CardTypeRes) :
		return _check_type.call(x, _check_type))
