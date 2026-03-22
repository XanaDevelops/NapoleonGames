
## Casilla del mapa ([TileRes](scripts/resources/tile_res.gd))[br]
##
## Representa una casilla individual del mapa.[br]
##
## [br]
##
## Atributos:[br]
## - height: Altura o nivel del mar.[br]
## - type: Tipo de casilla ([TileTypeRes](scripts/resources/tile_type_res.gd)).[br]
##
class_name TileRes
extends GameResource

## Altura o nivel del mar
@export var height:= 0 #nivel del mar
## Tipo de casilla ([TileTypeRes](scripts/resources/tile_type_res.gd))
@export var type: TileTypeRes
