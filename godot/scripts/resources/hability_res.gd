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
	if not is_valid_objective(objective):
		objective = SEL_ENEMY_FLAG
		push_error("Habilidad sin objetivo valido!\nValor por defecto ENEMY")
		assert(false)

## true si la habilidad afecta a uno mismo
static func inflicts_self(obj: int) -> bool:
	return obj & SEL_SELF_FLAG
	
## true si la habilidad afecta a uno mismo
func _inflicts_self(obj: int) -> bool:
	return inflicts_self(obj)
	
## true si la habilidad afecta a los aliados (no te incluye!)
static func inflicts_ally(obj: int) -> bool:
	return obj & SEL_ALLY_FLAG

## true si la habilidad afecta a los aliados (no te incluye!)
func _inflicts_ally(obj: int) -> bool:
	return inflicts_ally(obj)

## true si la habilidad afecta a los enemigos
static func inflicts_enemy(obj: int) -> bool:
	return obj & SEL_ENEMY_FLAG

## true si la habilidad afecta a los enemigos
func _inflicts_enemy(obj: int) -> bool:
	return inflicts_enemy(obj)
	
static func inflicts_single(obj: int) -> bool:
	return not inflicts_multiple(obj)

## true si la habilidad afecta a un solo objetivo
func _inflicts_single(obj: int) -> bool:
	return inflicts_single(obj)
		
static func inflicts_multiple(obj: int) -> bool:
	return obj & SEL_MULT_FLAG

## true si la habilidad afecta a multiples objetivos
func _inflicts_multiple(obj: int) -> bool:
	return inflicts_multiple(obj)
	
static func is_valid_objective(obj: int) -> bool:
	if obj <= 0 or obj > 0b1111:
		return false
	if obj == (SEL_SELF_FLAG | SEL_MULT_FLAG):
		return false
	if obj == SEL_MULT_FLAG:
		return false
		
	return true

## true si el objetivo de la habilidad es valido
func _is_valid_objective(obj: int) -> bool:
	return is_valid_objective(obj)
	
static func objective_text(obj: int) -> String:
	if not HabilityRes.is_valid_objective(obj):
		return "Inválido"
	var is_self     := HabilityRes.inflicts_self(obj)
	var is_enemy    := HabilityRes.inflicts_enemy(obj)
	var is_ally     := HabilityRes.inflicts_ally(obj)
	var is_multiple := HabilityRes.inflicts_multiple(obj)
	
	var parts: Array[String] = []
	
	if is_self:
		parts.append("Uno mismo")

	if is_enemy and is_ally:
		# en playtest (si da tiempo) ver si es obvio la diferencia entre self i el resto de flags
		parts.append("Todos" if is_multiple else "Cualquier único")
	elif is_enemy:
		parts.append("Enemigos" if is_multiple else "Enemigo único")
	elif is_ally:
		parts.append("Aliados" if is_multiple else "Aliado único")

	return " + ".join(parts)
	
func _objective_text() -> String:
	return objective_text(objective)
			
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
