
## Estadística ([StatData])[br]
##
## Define una estadística que puede ser modificada en el juego.[br]
##
## [br]
##
## Atributos:[br]
## - name: Nombre de la estadística.[br]
## - desc: Descripción de la estadística.[br]
## - isPercent: Indica si es un valor porcentual.[br]
##
class_name StatData
extends GameResource

## Nombre de la estadística
@export var name: StringName
## Descripción de la estadística
@export var desc: String
## Indica si es un valor porcentual
@export var isPercent := false

## Para diferenciar si un AlterStateRes es a la resistencia a ese valor o al ataque 
## la StatData se llama &"defense" o &"attack"

## Resistencia a un valor
static var DEFENSE := &"defense"

## Ataque de un valor
static var ATTACK := &"attack"

## Velocidad de movimiento
static var SPEED := &"speed"

## Vida actual (para curar) atacar -> ATTACK
static var HEALTH := &"hp"

## Vida maxima
static var MAX_HEALTH := &"max_health"

## Altura de la unidad
static var HEIGHT := &"height"

## Mana actual
static var MANA := &"mana"

## Mana maximo
static var MAX_MANA := &"max_mana"

#Los valors MAX es por si se quiere hacer algo que afecte al total
# por ejemplo, curar un 20% de vida maxima, NO afecta al valor máximo (aunque se pueda hacer...)

## Placeholder de script de traducir nombres de estadisticas que la BD al interno del juego
## Si hiciera falta...
static func translate_name(name: StringName) -> StringName:
	return name
