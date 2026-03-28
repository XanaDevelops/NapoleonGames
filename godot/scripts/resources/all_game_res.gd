## Todos los recursos del juego ([GameResources])[br]
##
## Recurso contenedor que agrupa colecciones de todos los recursos principales usados en el juego.[br]
##
## [br]
##
## Atributos:[br]
## - metadata: Metadatos del proyecto ([MetadataRes]).[br]
## - users: Lista de usuarios ([UserRes]).[br]
## - card_types: Tipos de carta ([CardTypeRes]).[br]
## - cards: Cartas jugables ([CardRes]).[br]
## - attack_types: Tipos de ataque ([AttackType]).[br]
## - habilities: Habilidades ([HabilityRes]).[br]
## - tile_mods: Modificadores de casilla ([TileModRes]).[br]
## - tile_types: Tipos de casilla ([TileTypeRes]).[br]
## - tiles: Casillas ([TileRes]).[br]
## - maps: Mapas ([MapRes]).[br]
## - armies: Ejércitos ([ArmyRes]).[br]
## - stats: Estadísticas ([StatData]).[br]
## - alter_states: Estados alterados ([AlterStateRes]).[br]
##
class_name GameResources
extends GameResource

# Path por defecto
const _path := "res://resources/all_game_res.tres"

## Metadatos del conjunto de recursos
@export var metadata: MetadataRes
## Lista de usuarios
@export var users: Array[UserRes] = []
## Tipos de carta
@export var card_types: Array[CardTypeRes] = []
## Cartas jugables
@export var cards: Array[CardRes] = []
## Tipos de ataque
@export var attack_types: Array[AttackType] = []
## Habilidades
@export var habilities: Array[HabilityRes] = []
## Modificadores de casilla
@export var tile_mods: Array[TileModRes] = []
## Tipos de casilla
@export var tile_types: Array[TileTypeRes] = []
## Casillas
@export var tiles: Array[TileRes] = []
## Mapas
@export var maps: Array[MapRes] = []
## Ejércitos
@export var armies: Array[ArmyRes] = []
## Estadísticas
@export var stats: Array[StatData] = []
## Estados alterados
@export var alter_states: Array[AlterStateRes] = []

# Guarda este `GameResources` en `path`. Devuelve el código de error de ResourceSaver.
func save_to(path:= _path) -> int:
	return ResourceSaver.save(self, path)

# Carga y retorna un `GameResources` desde `path` o `null` si no existe o no es del tipo esperado.
static func load_from(path: = _path) -> GameResources:
	var res := ResourceLoader.load(path)
	if res is GameResources:
		return res
	return null

