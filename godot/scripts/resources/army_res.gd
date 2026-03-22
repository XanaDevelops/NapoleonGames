
## Ejército ([ArmyRes](scripts/resources/army_res.gd))[br]
##
## Recurso que representa un ejército de cartas.[br]
##
## [br]
##
## Atributos:[br]
## - nom: Nombre del ejército.[br]
## - isActive: Indica si está activo.[br]
## - agrupations: Agrupaciones de cartas y cantidad (Dictionary[[CardRes](scripts/resources/card_res.gd), int]).[br]
##
class_name ArmyRes
extends GameResource

const MAX_SIZE := 20

## Nombre del ejército (identificador)
@export var nom: StringName
## Indica si está activo
@export var isActive:= false
## Agrupaciones de cartas y cantidad (Dictionary[[CardRes](scripts/resources/card_res.gd), int])
@export var agrupations: Dictionary[CardRes, int]
