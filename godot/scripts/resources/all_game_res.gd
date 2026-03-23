## Todos los recursos del juego ([GameResources](scripts/resources/all_game_res.gd))[br]
##
## Recurso contenedor que agrupa colecciones de todos los recursos principales usados en el juego.[br]
##
## [br]
##
## Atributos:[br]
## - metadata: Metadatos del proyecto ([MetadataRes](scripts/resources/metadata_res.gd)).[br]
## - users: Lista de usuarios ([UserRes](scripts/resources/user_res.gd)).[br]
## - card_types: Tipos de carta ([CardTypeRes](scripts/resources/card_type_res.gd)).[br]
## - cards: Cartas jugables ([CardRes](scripts/resources/card_res.gd)).[br]
## - attack_types: Tipos de ataque ([AttackType](scripts/resources/attack_type_res.gd)).[br]
## - habilities: Habilidades ([HabilityRes](scripts/resources/hability_res.gd)).[br]
## - tile_mods: Modificadores de casilla ([TileModRes](scripts/resources/tile_mod_res.gd)).[br]
## - tile_types: Tipos de casilla ([TileTypeRes](scripts/resources/tile_type_res.gd)).[br]
## - tiles: Casillas ([TileRes](scripts/resources/tile_res.gd)).[br]
## - maps: Mapas ([MapRes](scripts/resources/map_res.gd)).[br]
## - armies: Ejércitos ([ArmyRes](scripts/resources/army_res.gd)).[br]
## - stats: Estadísticas ([StatData](scripts/resources/stat_res.gd)).[br]
## - alter_states: Estados alterados ([AlterStateRes](scripts/resources/alter_state_res.gd)).[br]
##
class_name GameResources
extends GameResource

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
