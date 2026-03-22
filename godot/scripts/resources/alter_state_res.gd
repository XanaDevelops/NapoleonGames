
## Estado alterado ([AlterStateRes](scripts/resources/alter_state_res.gd))[br]
##
## Define un estado alterado que puede afectar a una carta o unidad.[br]
##
## [br]
##
## Atributos:[br]
## - objectiu: Objetivo del estado alterado ([HabilityRes.HAB_DEST](scripts/resources/hability_res.gd)).[br]
## - value: Valor del estado alterado.[br]
## - hitP: Probabilidad de aplicación.[br]
## - duration: Duración en turnos.[br]
##
class_name AlterStateRes
extends GameResource

## Objetivo del estado alterado ([HabilityRes.HAB_DEST](scripts/resources/hability_res.gd))
@export var objectiu := HabilityRes.HAB_DEST.SELF #Si nos ponemos creativos puede ser diferente a self
## Valor del estado alterado
@export var value: float
## Probabilidad de aplicación
@export var hitP := 1.0
## Duración en turnos
@export var duration: int
