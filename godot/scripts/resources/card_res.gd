class_name CardRes
extends Resource

# recurso de una carta
# valores asumidos del modelo de la BD

@export var name: String
@export var desc: String
@export var hp: int
@export var mana: int
@export var speed: int  #valor de la velocidad
@export var dodge: float
@export var img: Texture2D
@export var resistances: Dictionary[AttackType, int]
@export var habilities: Array[HabilityRes]
@export var types: Array[CardType]
