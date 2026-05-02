## Todos los recursos del juego ([GameResources])[br]
##
## Recurso contenedor que agrupa colecciones de todos los recursos principales usados en el juego.[br]
##
## [br]
##
## Atributos (IMPORTANTE: no modificar directamente):[br]
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
const _asset_folder := "res://assets/"

const DELETE_AFTER_PACK := false

var _cache : Dictionary[Script, Dictionary] = {}

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

# Actualiza la cache desde las variables
func _update_cache(called_from_load_from:= false) -> void:
	# TODO: Placeholder de cache
	for prop in get_property_list():
		# filtrar
		if prop.usage & PropertyUsageFlags.PROPERTY_USAGE_DEFAULT and \
			prop.usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE:
				if prop.type >= TYPE_ARRAY:
					var elems : Array = get(prop.name)
					var scr : Script = elems.get_typed_script()
					for e: GameResource in elems:
						set_in_cache(e, called_from_load_from)
				else:
					# metadata
					pass

# Guarda este `GameResources` en `path`. Devuelve el código de error de ResourceSaver.
func save_to(path:= _path) -> int:
	return ResourceSaver.save(self, path)

# Carga y retorna un `GameResources` desde `path` o `null` si no existe o no es del tipo esperado.
static func load_from(path: = _path) -> GameResources:
	var res := ResourceLoader.load(path)
	if res is GameResources:
		res._update_cache(true)
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
	CardArmyGroup,
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

	var plural := script_name.to_snake_case() # + "s"
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
	
## Extrae los recursos contenidos en la carpeta destino
## Además, deja GameResources con las referencias a los archivos
## TODO: metadata
func unpack(folder := _folder) -> void:
	for scr : Script in self.game_resources:
		var folder_name := get_folder_name(scr)
		if scr == MetadataRes:
			pass
		else:
			var arr = self.get(folder_name)
			if arr == null:
				continue
			for res in arr:
				if res == null:
					continue
				_unpack(res, folder + folder_name + "/")
				


## Guarda en un archivo acorde en la carpeta root
func _unpack(res: GameResource, root: String) -> void:
	var fname := str(res.uid).lpad(4, "0") + ".tres"
	var path := root + fname
	DirAccess.make_dir_recursive_absolute(root)
	var new_res := GameResource.parse_json(JSON.stringify(res.to_json_dict()))
	var err := ResourceSaver.save(new_res, path)
	if err != OK:
		push_warning("Failed saving resource: " + path + " err=" + str(err))
		return
		
	set_in_cache(load(path))

## Importar desde la carpeta folder
## TODO: metadata
func pack(folder := _folder) -> void:
	_cache.clear()
	for scr : Script in self.game_resources:
		var folder_name := get_folder_name(scr)
		if scr == MetadataRes:
			pass
		else:
			if self.get(folder_name) != null:
				(self.get(folder_name) as Array).clear()
		for file in ResourceLoader.list_directory(folder+folder_name):
			var path := folder+folder_name+"/"+file
			print("Cargando: " + path)
			var res : GameResource = ResourceLoader.load(path, scr.get_global_name())
		
			var new_res := GameResource.parse_json(JSON.stringify(res.to_json_dict()))

			#print(res.get_script())
			if scr == MetadataRes:
				pass
			else:
				set_in_cache(new_res)
				
	if DELETE_AFTER_PACK:
		for scr : Script in self.game_resources:
			var folder_name := get_folder_name(scr)
			if scr == MetadataRes:
				pass
			else:
				self.set(folder_name, [])
			var dirFolder := DirAccess.open(folder+folder_name)
			for file in ResourceLoader.list_directory(folder+folder_name):
				var path := folder+folder_name+"/"+file
				dirFolder.remove(path)


## Devuelve el GameRes que coincida con el tipo y uid
## si no, devuelve null
func get_res_from_uid(uid: int, gameRes : Script) -> GameResource:
	if gameRes not in _cache:
		push_warning("Se ha intentado obtener ", gameRes.get_global_name(), ":", uid, "\nPero no existe")
		return null	
		
	return _cache.get(gameRes).get(uid)
	
## Guarda un nuevo recurso en cache
func set_in_cache(gameRes : GameResource, called_from_load_from:=false) -> void:
	var scr : Script = gameRes.get_script()
	
	# guardar en cache
	if scr not in _cache:
		_cache.set(scr, {})
	var _dict : Dictionary = _cache.get(scr)
	
	var has := _dict.has(gameRes.uid)
	_dict.set(gameRes.uid, gameRes)
	
	if called_from_load_from:
		# evitar duplicidades en como esta creado esto
		return
	
	# guardar en los arrays
	var name := get_folder_name(scr)
	
	if has:
		var arr : Array = self.get(name)
		var i := arr.find_custom(func (x:GameResource): return x.uid == gameRes.uid)
		#(arr[i] as GameResource).update_vals(gameRes)
		arr[i] = gameRes
		print("Actualizando ", scr.get_global_name(), " ", gameRes.uid)
	else:
		# comprobar que no sea un subrecurso que no interese tener en array
		# como CardArmyGroup
		var arr = self.get(name)
		if arr != null:
			(arr as Array).append(gameRes)
		
	#TODO: pensar si mantener ordenado esos arrays o no...

## Elimina un recurso de cache
## no se puede deshacer
## No trata las dependencias...
func del_from_cache(gameRes: GameResource) -> void:
	var scr : Script = gameRes.get_script()
	
	# guardar en cache
	if scr not in _cache:
		_cache.set(scr, {})
	var _dict : Dictionary = _cache.get(scr)
	
	var has := _dict.erase(gameRes.uid)
		
	# borrar en los arrays
	var name := get_folder_name(scr)
	if has:
		var arr : Array = self.get(name)
		arr.erase(gameRes)
