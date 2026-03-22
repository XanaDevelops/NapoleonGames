class_name HabilityRes
extends Resource

enum HAB_DEST {SELF,
	SINGLE_ENEMY, MULTI_ENEMY,
	SINGLE_ALLY, MULTIPLE_ALLY,
	SINGLE_ANY, MULTIPLE_ANY, 
	EVERYONE}



@export var objective := HAB_DEST.SINGLE_ENEMY
@export var value: float ## FIXME: mirar despues con los int?!
@export var stat: StatData
@export var attackType: AttackType
@export var manaCost := 0
@export var duration := 0  #duracion en turnos 0 inmediato 
@export var isPassive := false
@export var alter_states: Array[AlterStateRes]
