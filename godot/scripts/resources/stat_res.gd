
## Estadística ([StatData](scripts/resources/stat_res.gd))[br]
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
