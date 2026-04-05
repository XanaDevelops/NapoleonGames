## Recurso de usuario ([UserRes])[br]
##
## Representa la información de un usuario en el juego.[br]
##
## [br]
##
## Atributos:[br]
## - name: Nombre real del usuario.[br]
## - username: Nombre de usuario único.[br]
## - img: Imagen o avatar del usuario ([Texture2D]).[br]
## - token: Token de autenticación del usuario.[br]
## - avariableCards: Cartas disponibles para el usuario (Array[[CardRes]]).[br]
## - avariableMaps: Mapas disponibles para el usuario (Array[[MapRes]]).[br]
## - userArmys: Ejércitos del usuario (Array[[ArmyRes]]).[br]
## - friends: Lista de amigos del usuario (Array[[UserRes]]).[br]
##
class_name UserRes
extends GameResource

## Nombre real del usuario
@export var name: String
## Nombre de usuario único
@export var username: StringName
## correo
@export var email: String
## Imagen o avatar del usuario ([Texture2D])
@export var img: Texture2D

## TODO: rol (rol del usuario, pendiente de implementar)

## Token de autenticación del usuario
@export var token: String

## Cartas disponibles para el usuario (Dictionary[CardRes, int])
@export var avariableCards: Dictionary[CardRes, int] = {}
## Mapas disponibles para el usuario (Array[[MapRes]])
@export var avariableMaps: Array[MapRes] = []
## Ejércitos del usuario (Array[[ArmyRes]])
@export var userArmys: Array[ArmyRes] = []

## Lista de amigos del usuario (Array[[UserRes]])
@export var friends: Array[UserRes] = []
