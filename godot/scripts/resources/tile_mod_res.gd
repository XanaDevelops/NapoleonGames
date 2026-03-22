
## Modificador de casilla ([TileModRes](scripts/resources/tile_mod_res.gd))[br]
## Define un modificador que afecta a una casilla.[br]
## [br]
## Atributos:[br]
## - value: Valor del modificador.[br]
## - stat: Estadística afectada ([StatData](scripts/resources/stat_res.gd)).[br]
## - affectType: Tipo de carta afectada ([CardTypeRes](scripts/resources/card_type_res.gd)).[br]
class_name TileModRes
extends GameResource

## Valor del modificador
@export var value: float
## Estadística afectada ([StatData](scripts/resources/stat_res.gd))
@export var stat: StatData
## Tipo de carta afectada ([CardTypeRes](scripts/resources/card_type_res.gd))
@export var affectType: CardTypeRes
