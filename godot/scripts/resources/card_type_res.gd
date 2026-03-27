## Tipo de carta ([CardTypeRes])[br]
##
## Define un tipo de carta y su jerarquía.[br]
##
## [br]
##
## Atributos:[br]
## - parentType: Tipo de carta padre ([CardTypeRes]).[br]
## - name: Nombre del tipo de carta.[br]
## - desc: Descripción del tipo de carta.[br]
##
class_name CardTypeRes
extends GameResource

## Tipo de carta padre ([CardTypeRes])
@export var parentType: CardTypeRes = null
## Nombre del tipo de carta
@export var name: StringName
## Descripción del tipo de carta
@export var desc: String 
