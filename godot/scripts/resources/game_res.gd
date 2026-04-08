
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
		return (key as GameResource).uid
	
	if typeof(key) <= TYPE_STRING or typeof(key) == TYPE_STRING_NAME:
		return key
		
	push_warning("TODO acabar _get_key_repr ")
	return key
		
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
						body.set(prop.name, 
							{GR_MARK+type_key.get_global_name(): _process_dict_value(dict)})
					else:
						push_warning("TODO: Dictionary[Object, _] ", prop.name)
				TYPE_OBJECT:
					var obj : Variant = get(prop.name)
					if obj == null:
						body.set(prop.name, null)
						continue
						
					var typed : Script = obj.get_script()
					if typed.get_base_script() == GameResource:
						body.set(prop.name, {GR_MARK+typed.get_global_name(): (obj as GameResource).uid})
					else:
						push_warning("No es un GameResource ", typed)
				_:
					push_error("what? GameResource tiene: ", prop.type)
	return body
	
	
func compare(res: GameResource) -> bool:
	return self.get_script() == res.get_script() and self.uid == res.uid
