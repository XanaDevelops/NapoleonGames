
## Tipo de casilla ([TileTypeRes])[br]
##Define el tipo de casilla del mapa y sus modificadores.[br]
## [br]
##Atributos:[br]
## - name: Nombre del tipo de casilla.[br]
## - desc: Descripción del tipo de casilla.[br]
## - mods: Modificadores aplicados a la casilla (Array[[TileModRes]]).[br]
class_name TileTypeRes
extends GameResource

## Nombre del tipo de casilla (identificador)
@export var name: StringName
## Descripción del tipo de casilla
@export var desc: String
## Modificadores aplicados a la casilla (Array[[TileModRes]])
@export var mods: Array[TileModRes] = []
## Textura de la casilla
@export var texture: Texture2D
