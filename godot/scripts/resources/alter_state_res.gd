
## Estado alterado ([AlterStateRes])[br]
##
## Define un estado alterado que puede afectar a una carta o unidad.[br]
##
## [br]
##
## Atributos:[br]
## - objectiu: Objetivo del estado alterado ([HabilityRes.HAB_DEST]).[br]
## - value: Valor del estado alterado.[br]
## - stat: Estadistica a la que afecta
## - type: Tipo del ataque (si stat es defensa
## - hitP: Probabilidad de aplicación.[br]
## - duration: Duración en turnos.[br]
##
class_name AlterStateRes
extends GameResource

## Objetivo del estado alterado ([HabilityRes.HAB_DEST])
@export var objectiu := HabilityRes.HAB_DEST.SELF #Si nos ponemos creativos puede ser diferente a self
## Valor del estado alterado
@export var value: float
## Estadistica a la que afecta
@export var stat: StatData
## Tipo del ataque
@export var type: AttackType
## Probabilidad de aplicación
@export var hitP := 1.0
## Duración en turnos
@export var duration: int
