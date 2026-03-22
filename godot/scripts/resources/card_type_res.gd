## Tipo de carta ([CardTypeRes](scripts/resources/card_type_res.gd))[br]
##
## Define un tipo de carta y su jerarquía.[br]
##
## [br]
##
## Atributos:[br]
## - parentType: Tipo de carta padre ([CardTypeRes](scripts/resources/card_type_res.gd)).[br]
## - name: Nombre del tipo de carta.[br]
## - desc: Descripción del tipo de carta.[br]
##
class_name CardTypeRes
extends GameResource

## Tipo de carta padre ([CardTypeRes](scripts/resources/card_type_res.gd))
@export var parentType: CardTypeRes = null
## Nombre del tipo de carta
@export var name: StringName
## Descripción del tipo de carta
@export var desc: String 
