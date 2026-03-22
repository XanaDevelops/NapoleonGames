
## Mapa del juego ([MapRes](scripts/resources/map_res.gd))[br]
##
## Define un mapa jugable y sus dimensiones.[br]
##
## [br]
##
## Atributos:[br]
## - name: Nombre del mapa.[br]
## - desc: Descripción del mapa.[br]
## - tamX: Tamaño horizontal.[br]
## - tamY: Tamaño vertical.[br]
##
class_name MapRes
extends GameResource

## Nombre del mapa (identificador)
@export var name: StringName
## Descripción del mapa
@export var desc: String
## Tamaño horizontal
@export var tamX: int
## Tamaño vertical
@export var tamY: int
