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
const _folder := "res://resources/"
const _path := _folder + "all_game_res.tres"

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
@export var stat_datas: Array[StatData] = []
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
	
# Orden manual de packeo: lista de etiquetas de tipo (carpetas)
static var game_resources: Array[Script] = [
	StatData,
	AttackType,
	CardTypeRes,
	AlterStateRes,
	HabilityRes,
	TileModRes,
	TileTypeRes,
	TileRes,
	MapRes,
	CardRes,
	ArmyRes,
	UserRes,
	MetadataRes,
]

static func get_folder_name(scr: Script) -> StringName:
	if not scr:
		return &""
		
	var script_name : StringName = scr.get_global_name()
	
	# Quitar sufijos comunes
	if script_name.ends_with("Res"):
		script_name = script_name.substr(0, script_name.length() - 3)
	elif script_name.ends_with("Resource"):
		script_name = script_name.substr(0, script_name.length() - 8)

	var plural := _camel_to_snake(script_name) # + "s"
	if not plural.ends_with("s"):
		if plural.ends_with("y"):
			plural = plural.substr(0, plural.length() - 1) + "ies"
		else:
			plural = plural + "s"

	return plural
	

## A lo mejor mover esto a GameResource.gd?
# Devuelve el nombre de la carpeta (snake_case plural) para un recurso `GameResource`
static func get_folder_name_for_resource(res: GameResource) -> StringName:
	if not res:
		return &""
		
	return get_folder_name(res.get_script())

static func _camel_to_snake(name: String) -> String:
	var out := ""
	var i := 0
	for ch in name:
		if i > 0 and ch == ch.to_upper() and ch != ch.to_lower():
			out += "_"
		out += ch.to_lower()
		i += 1
	return out

static func _pad_left_zeros(val, width := 4) -> String:
	var s := str(val)
	while s.length() < width:
		s = "0" + s
	return s
	
## Extrae los recursos contenidos en la carpeta destino
## TODO: metadata
func unpack(folder := _folder) -> void:
	for scr : Script in self.game_resources:
		var folder_name := get_folder_name(scr)
		if scr == MetadataRes:
			pass
		else:
			var arr : Array = self.get(folder_name)
			if arr == null:
				continue
			for res in arr:
				if res == null:
					continue
				var fname := _pad_left_zeros(res.uid, 4) + ".tres"
				var path := folder + folder_name + "/" + fname
				var err := ResourceSaver.save(res, path)
				if err != OK:
					push_warning("Failed saving resource: " + path + " err=" + str(err))
	
## Importar desde la carpeta folder
## TODO: metadata
func pack(folder := _folder) -> void:
	for scr : Script in self.game_resources:
		var folder_name := get_folder_name(scr)
		if scr == MetadataRes:
			pass
		else:
			self.set(folder_name, [])
		for file in ResourceLoader.list_directory(folder+folder_name):
			var path := folder+folder_name+"/"+file
			print("Cargando: " + path)
			var res := ResourceLoader.load(path, scr.get_global_name())
			print(res.get_script())
			if scr == MetadataRes:
				pass
			else:
				var i : int = self.get(folder_name).find_custom(func (e: GameResource): return e.uid == res.uid)
				print("i: " + str(i))
				if i == -1: # no lo tenemos
					print(folder_name)
					print(self.get(folder_name))
					self.get(folder_name).append(res)
					#pass
				else:
					push_warning("Recurso duplicado??")

	
		
