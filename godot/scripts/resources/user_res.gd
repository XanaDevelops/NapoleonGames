## Recurso de usuario ([UserRes](scripts/resources/user_res.gd))[br]
##
## Representa la información de un usuario en el juego.[br]
##
## [br]
##
## Atributos:[br]
## - name: Nombre real del usuario.[br]
## - username: Nombre de usuario único.[br]
## - img: Imagen o avatar del usuario ([Texture2D](https://docs.godotengine.org/en/stable/classes/class_texture2d.html)).[br]
## - token: Token de autenticación del usuario.[br]
## - avariableCards: Cartas disponibles para el usuario (Array[[CardRes](scripts/resources/card_res.gd)]).[br]
## - avariableMaps: Mapas disponibles para el usuario (Array[[MapRes](scripts/resources/map_res.gd)]).[br]
## - userArmys: Ejércitos del usuario (Array[[ArmyRes](scripts/resources/army_res.gd)]).[br]
## - friends: Lista de amigos del usuario (Array[[UserRes](scripts/resources/user_res.gd)]).[br]
##
class_name UserRes
extends GameResource

## Nombre real del usuario
@export var name: String
## Nombre de usuario único
@export var username: StringName
## Imagen o avatar del usuario ([Texture2D](https://docs.godotengine.org/en/stable/classes/class_texture2d.html))
@export var img: Texture2D

## TODO: rol (rol del usuario, pendiente de implementar)

## Token de autenticación del usuario
@export var token: String

## Cartas disponibles para el usuario (Array[[CardRes](scripts/resources/card_res.gd)])
@export var avariableCards: Array[CardRes] = []
## Mapas disponibles para el usuario (Array[[MapRes](scripts/resources/map_res.gd)])
@export var avariableMaps: Array[MapRes] = []
## Ejércitos del usuario (Array[[ArmyRes](scripts/resources/army_res.gd)])
@export var userArmys: Array[ArmyRes] = []

## Lista de amigos del usuario (Array[[UserRes](scripts/resources/user_res.gd)])
@export var friends: Array[UserRes] = []
