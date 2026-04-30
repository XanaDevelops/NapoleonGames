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

## Máscara que afecta a la misma unidad
const SEL_SELF_FLAG := 0b0001
## Máscara que afecta a los aliados
const SEL_ALLY_FLAG := 0b0010
## Máscara que afecta a los enemigos
const SEL_ENEMY_FLAG := 0b0100
## Máscara que indica multiplicidad
const SEL_MULT_FLAG := 0b1000

enum CONDITION {
	LT, GT, EQ, LE, GE, NE,
	NA ## Not Aplicable
}

## Nombre de la habilidad
@export var name : StringName
##Descripción de la habilidad
@export var desc : String
## Objetivo de la habilidad (enum HAB_DEST)
@export_flags("self:1", "ally:2", "enemy:4", "multiple:8", "everyone:15")
var objective := SEL_ENEMY_FLAG
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
@export var duration := 0  # (0 solo actua ese turno)
## Cooldown en turnos
@export var cooldown := 1 # (1, en el siguiente está disponible
## Probabilidad de acierto
@export var hitP := 1.0
## Indica si es pasiva
@export var isPassive := false
## Estados alterados aplicados (Array[[AlterStateRes]])
@export var alter_states: Array[AlterStateRes]
## tipo de condicion de la habilidad
@export var condition:= CONDITION.NA
## estadistica a comparar
@export var condition_stat : StatData = null
## valor a comparar
@export var condition_value := 0.0

func _init() -> void:
	if objective == 0:
		objective = SEL_ENEMY_FLAG
		push_error("Habilidad sin objetivo valido!\nValor por defecto ENEMY")
		assert(false)

## true si la habilidad afecta a uno mismo
static func inflicts_self(obj: int) -> bool:
	return obj & SEL_SELF_FLAG
	
## true si la habilidad afecta a los aliados (no te incluye!)
static func inflicts_ally(obj: int) -> bool:
	return obj & SEL_ALLY_FLAG

## true si la habilidad afecta a los enemigos
static func inflicts_enemy(obj: int) -> bool:
	return obj & SEL_ENEMY_FLAG
	
static func inflicts_single(obj: int) -> bool:
	return not inflicts_multiple(obj)
		
static func inflicts_multiple(obj: int) -> bool:
	return obj & SEL_MULT_FLAG
			
## Comprueba si se cumple la condición dado el valor de entrada
func applies(value_check: float) -> bool:
	match self.condition:
		CONDITION.LT:
			return value_check < self.condition_value
		CONDITION.LE:
			return value_check <= self.condition_value
		CONDITION.GT:
			return value_check > self.condition_value
		CONDITION.GE:
			return value_check >= self.condition_value
		CONDITION.EQ:
			return value_check == self.condition_value
		CONDITION.NE:
			return value_check != self.condition_value
		_: # NA
			return true

func _is_single_target() -> bool:
	return self.objective in [
		self.HAB_DEST.SINGLE_ENEMY,
		self.HAB_DEST.SINGLE_ALLY,
		self.HAB_DEST.SINGLE_ANY,
	]
