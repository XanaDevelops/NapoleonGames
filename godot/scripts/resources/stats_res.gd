
## Conjunto de estadísticas ([AllStatsRes](scripts/resources/stats_res.gd))[br]
##
## Contiene todas las estadísticas disponibles para modificadores y habilidades.[br]
##
## [br]
##
## Atributos:[br]
## - stats: Lista de estadísticas (Array[[StatData](scripts/resources/stat_res.gd)]).[br]
##
class_name AllStatsRes
extends GameResource

## Lista de estadísticas (Array[[StatData](scripts/resources/stat_res.gd)])
@export var stats: Array[StatData] #Godot no tiene Set[], mirar si renta StringName
