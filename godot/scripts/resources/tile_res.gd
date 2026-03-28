
## Casilla del mapa ([TileRes])[br]
##
## Representa una casilla individual del mapa.[br]
##
## [br]
##
## Atributos:[br]
## - height: Altura o nivel del mar.[br]
## - type: Tipo de casilla ([TileTypeRes]).[br]
##
class_name TileRes
extends GameResource

## Altura, 0 nivel del mar
@export var height:= 0 
## Tipo de casilla ([TileTypeRes])
@export var type: TileTypeRes
