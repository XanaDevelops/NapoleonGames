extends Node

var usuario_actual: UserRes



func establecer_usuario_actual(nuevo_usuario: UserRes) -> void:
	usuario_actual = nuevo_usuario

func obtener_ejercitos() -> Array:
	if usuario_actual == null or usuario_actual.userArmys == null:
		return []
	return usuario_actual.userArmys

func existe_ejercito(nombre_a_comprobar: String) -> bool:
	var ejercitos = obtener_ejercitos()
	for ejercito in ejercitos:
		if ejercito.nom == nombre_a_comprobar:
			return true
	return false

func establecer_ejercito_activo(nombre_ejercito_a_activar: String) -> void:
	var ejercitos = obtener_ejercitos()
	for ejercito in ejercitos:
		ejercito.isActive = (ejercito.nom == nombre_ejercito_a_activar)

func guardar_ejercito(ejercito_a_guardar: ArmyRes, nombre_anterior: String) -> void:
	var ejercitos = usuario_actual.userArmys
	var encontrado = false
	
	for i in range(ejercitos.size()):
		if ejercitos[i].nom == nombre_anterior:
			ejercitos[i] = ejercito_a_guardar.clonar()
			encontrado = true
			break
			
	if not encontrado:
		ejercitos.append(ejercito_a_guardar.clonar())

func eliminar_ejercito(nombre_ejercito: String) -> void:
	var ejercitos = usuario_actual.userArmys
	var era_activo = false
	
	for i in range(ejercitos.size() - 1, -1, -1):
		if ejercitos[i].nom == nombre_ejercito:
			era_activo = ejercitos[i].isActive 
			ejercitos.remove_at(i)
			break
			
	if era_activo and ejercitos.size() > 0:
		ejercitos[0].isActive = true
