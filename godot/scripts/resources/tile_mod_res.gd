
## Modificador de casilla ([TileModRes])[br]
## Define un modificador que afecta a una casilla.[br]
## [br]
## Atributos:[br]
## - value: Valor del modificador.[br]
## - stat: Estadística afectada ([StatData]).[br]
## - affectType: Tipo de carta afectada ([CardTypeRes]).[br]
class_name TileModRes
extends GameResource

## Valor del modificador
@export var value: float
## Estadística afectada ([StatData])
@export var stat: StatData
## Tipo de carta afectada ([CardTypeRes])
@export var affectType: CardTypeRes
