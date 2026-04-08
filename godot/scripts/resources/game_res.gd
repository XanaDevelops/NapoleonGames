
## Recurso base del juego ([GameResource])[br]
##
## Clase base para agrupar recursos personalizados en el editor.[br]
##
@abstract
class_name GameResource
extends Resource

@export var uid : int

## Marca en los JSON que indica que el nombre es de una clase de Godot
## no el nombre de un atributo
const GR_MARK := &"@"

func _process_array(array: Array) -> Array:
	var typed : Script = array.get_typed_script()
	if typed == null:
		if array.get_typed_builtin() < TYPE_DICTIONARY:
			return array
		elif array.get_typed_builtin() == TYPE_DICTIONARY:
			var _aux : Array = []
			for a: Dictionary in array:
				var type_key : Script = a.get_typed_key_script()
				if type_key == null:
					pass
				elif type_key.get_base_script() == GameResource:
					_aux.append({GR_MARK+type_key.get_global_name(): _process_dict_value(a)})
			return _aux
		else: # es array de array
			var _aux : Array = []
			for a in array:
				_aux.append(_process_array(a))
			return _aux
	elif typed.get_base_script() == GameResource:
		return array.map(func (x: GameResource): 
						return {GR_MARK+typed.get_global_name(): x.uid})
	else:
		push_warning("TODO array: ", typed)
		return array
	
func _get_key_repr(key: Variant) -> Variant:
	if key is GameResource:
		return {GR_MARK+(key.get_script() as Script).get_global_name() :key.uid}
	
	if typeof(key) <= TYPE_STRING or typeof(key) == TYPE_STRING_NAME:
		return key
		
	push_warning("TODO acabar _get_key_repr ")
	return key

## auxiliar a to_json_dict()
func _process_dict_value(dict: Dictionary) -> Dictionary:
	var ret : Dictionary[Variant, Variant] = {}
	var type_val : Script = dict.get_typed_value_script()
	
	for key in dict:
		var key_repr : Variant = _get_key_repr(key)
		var value = dict[key]
		if type_val == null:
			if dict.get_typed_value_builtin() >= TYPE_ARRAY:
				ret.set(key_repr, _process_array((value as Array)))
			elif dict.get_typed_value_builtin() == TYPE_DICTIONARY:
				ret.set(key_repr, _process_dict_value((value as Dictionary)))
			else:
				ret.set(key_repr, value)
		elif type_val.get_base_script() == GameResource:
			ret.set(key_repr, (value as GameResource).uid)
		else:
			push_warning("TODO: _process Object")
			ret.set(key_repr, value)
	
	return ret

## Devuelve un diccionario adaptado para transformar a json para 
## ApiAdapter
func to_json_dict() -> Dictionary[String, Variant]:
	var body : Dictionary[String, Variant] = {}
	for prop in get_property_list():
		# filtrar
		if prop.usage & PropertyUsageFlags.PROPERTY_USAGE_DEFAULT and \
			prop.usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE:
			#print(prop)
			match prop.type:
				# tipos bases
				var t when (t <= TYPE_STRING and t > 0) or t == TYPE_STRING_NAME:
					body.set(prop.name, get(prop.name))
				# arrays
				var t when t >= TYPE_ARRAY:
					var array : Array = get(prop.name)
					body.set(prop.name, self._process_array(array))
				
				TYPE_DICTIONARY:
					print("TODO dict: ", prop.name)
					var dict : Dictionary = get(prop.name)
					var type_key : Script = dict.get_typed_key_script()

					# caso base
					# FIXME, no vamos a tener un Dictionary[Array, _], verdad?
					# asumimos Dictionary[int/string, _] o [GameRes, _]
					if type_key	== null:
						if dict.get_typed_key_builtin() >= TYPE_ARRAY:
							push_warning("TODO: Dictionary[Array, _]")
						else:
							body.set(prop.name, _process_dict_value(dict))
					elif type_key.get_base_script() == GameResource:
						body.set(prop.name, _process_dict_value(dict))
					else:
						push_warning("TODO: Dictionary[Object, _] ", prop.name)
				TYPE_OBJECT:
					var obj : Variant = get(prop.name)
					if obj == null:
						body.set(prop.name, null)
						continue
						
					var typed : Script = obj.get_script()
					if typed != null and typed.get_base_script() == GameResource:
						body.set(prop.name, {GR_MARK+typed.get_global_name(): (obj as GameResource).uid})
					else:
						push_warning("No es un GameResource ", typed)
				_:
					push_error("what? GameResource tiene: ", prop.type)
	return {GR_MARK+(get_script() as Script).get_global_name(): body}
	
## Auxiliar a parse_json()
static func _parse_dictionary(dict: Dictionary) -> Variant:
	var keys : Array = dict.keys()
	var key0 : String = keys[0]
	# Si tenemos la referencia a un GameResource
	if keys.size() == 1 and get_script_from_json_text(key0) != null and dict[key0] is float:
		return GameManagerNode.get_game_resources().get_res_from_uid(dict[key0], get_script_from_json_text(key0))
	
	var res : Dictionary = {}
	for key in keys:
		var key_type := typeof(key)
		var _key
		#Comprobar si es un GameRes (se parsea como string)
		if key_type == TYPE_STRING:
			var _aux = JSON.parse_string(key)
			if _aux != null:
				var _res = _parse_dictionary(_aux)
				if _res is GameResource:
					_key = _res
				else:
					_key = key
			else:
				_key = key
		
		var value : Variant = dict[key]
		var value_type := typeof(value)
		
		if value_type == TYPE_DICTIONARY:
			res.set(_key, _parse_dictionary(value))
		elif value_type >= TYPE_ARRAY:
			res.set(_key, _parse_array(value))
		else:
			res.set(_key, value)
	return res
	
## Auxiliar de parse_json
static func _parse_array(array: Array) -> Array:
	var type = array.get_typed_builtin()
	if type >= TYPE_ARRAY:
		return array.map(func (a:Array): return _parse_array(a))
	if type == TYPE_DICTIONARY:
		return array.map(func (d: Dictionary):
				return _parse_dictionary(d))
	return array
	
## Parsea un texto JSON a un GameResource
static func parse_json(json_text : String) -> GameResource:
	var json : Dictionary = JSON.parse_string(json_text)
	var key : String = json.keys()[0]
	var game_res_scr : Script = get_script_from_json_text(key)
	print("parseando un ", game_res_scr)
	var game_res : GameResource = game_res_scr.new()

	for param in json[key]:
		if param not in game_res:
			push_error("JSON malformado, no existe ", param)
			return null
		var value : Variant = json[key][param]
		
		# Si es diccionario o GameRes
		if typeof(value) == TYPE_DICTIONARY:
			value = (value as Dictionary)
			var set_val = _parse_dictionary(value)
			# ya que puede devolver un GameRes o un Dict
			if typeof(set_val) == TYPE_DICTIONARY:
				game_res.get(param).assign(set_val) # ayuda con el casting
			else:
				game_res.set(param, set_val)
		# array
		elif typeof(value) >= TYPE_ARRAY:
			value = (value as Array)
			game_res.get(param).assign(_parse_array(value))
			
		else:
			game_res.set(param, value)
	return game_res
	
static func get_script_from_json_text(text: String) -> Script:
	if !text.begins_with(GR_MARK):
		push_error(text, " no tiene la marca de un GameResource")
		return null
	var scr_name := text.trim_prefix(GR_MARK)
	for res in GameResources.game_resources:
		if scr_name == res.get_global_name():
			return res
	
	push_error("No se reconoce ", text, " como GameResource")
	return null
	
func compare(res: GameResource) -> bool:
	return self.get_script() == res.get_script() and self.uid == res.uid
