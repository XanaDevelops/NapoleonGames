## Habilidad ([HabilityRes])[br]
##
## Define una habilidad que puede tener un objetivo, valor, estadística y otros efectos.[br]
##
## [br]
##
## Atributos:[br]
## - objective: Objetivo de la habilidad (enum HAB_DEST).[br]
## - value: Valor de la habilidad.[br]
## - manaCost: Coste de maná.[br]
## - duration: Duración en turnos.[br]
## - isPassive: Indica si es pasiva.[br]
## - alter_states: Estados alterados aplicados (Array[[AlterStateRes]]).[br]
##
class_name HabilityRes
extends GameResource

enum HAB_DEST {SELF,
	SINGLE_ENEMY, MULTI_ENEMY,
	SINGLE_ALLY, MULTIPLE_ALLY,
	SINGLE_ANY, MULTIPLE_ANY, 
	EVERYONE}

## Objetivo de la habilidad (enum HAB_DEST)
@export var objective := HAB_DEST.SINGLE_ENEMY
## Valor de la habilidad
@export var value: float ## FIXME: mirar despues con los int?!
## Estadística afectada ([StatData])
@export var stat: StatData
## Tipo de ataque ([AttackType])
@export var attackType: AttackType
## rango de la habilidad (en radio de casillas)
@export var radius: int  # conflicto con "range"
## Coste de maná
@export var manaCost := 0
## Duración en turnos
@export var duration := 0  #duracion en turnos 0 inmediato 
## Indica si es pasiva
@export var isPassive := false
## Estados alterados aplicados (Array[[AlterStateRes]])
@export var alter_states: Array[AlterStateRes]

## true si la habilidad afecta a uno mismo
static func inflicts_self(obj: HAB_DEST) -> bool:
	return obj == HAB_DEST.SELF or obj == HAB_DEST.EVERYONE
