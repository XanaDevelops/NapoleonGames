## Carta [br]
##
## Recurso que representa una carta jugable.[br]
##
## [br]
##
## Atributos:[br]
## - name: Nombre de la carta.[br]
## - desc: Descripción de la carta.[br]
## - hp: Puntos de vida.[br]
## - mana: Coste de maná.[br]
## - speed: Velocidad de la carta.[br]
## - dodge: Probabilidad de esquiva.[br]
## - img: Imagen de la carta.[br]
## - resistances: Resistencias por tipo de ataque.[br]
## - habilities: Habilidades de la carta.[br]
## - types: Tipos de carta.[br]
##
class_name CardRes
extends GameResource



## Nombre de la carta (identificador)
@export var name: StringName
## Descripción de la carta
@export var desc: String
## Puntos de vida
@export var hp: int
## Coste de maná
@export var mana: int
## Velocidad de la carta
@export var speed: int  #valor de la velocidad
## Probabilidad de esquiva
@export var dodge: float
## Imagen de la carta ([Texture2D])
@export var portrait: Texture2D #tambien podria ser path a la imagen
## Imagen para dentro del juego
@export var img: Texture2D
## Resistencias por tipo de ataque (Dictionary[[AttackType], int])
@export var resistances: Dictionary[AttackType, int]
## Habilidades de la carta (Array[[HabilityRes]])
@export var habilities: Array[HabilityRes]
## Tipos de carta (Array[[CardTypeRes]])
@export var types: Array[CardTypeRes]
