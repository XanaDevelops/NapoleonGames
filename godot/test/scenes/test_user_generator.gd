class_name TestUserGenerator
extends RefCounted

func generar_usuario_completo() -> UserRes:
	var user = UserRes.new()
	user.name = "DevPlayer"
	
	
	# 1. Mapas
	user.availableMaps.append(_generar_mapa_prueba(
		"Bosque de Pruebas", 
		"Un frondoso bosque ideal para emboscadas. Los árboles bloquean la visión."
	))
	user.availableMaps.append(_generar_mapa_prueba(
		"Ruinas del Editor", 
		"Restos de una antigua civilización con alta concentración de maná."
	))
	
	# 2. Cartas
	var carta_elfo = _generar_carta_prueba("Arquero Elfo", "Ataca a distancia.", 2, "res://assets/sprites/imagenes_de_cartas/elfo.jpg")
	var carta_esqueleto = _generar_carta_prueba("Guerrero Esqueleto", "Resiste bien.", 1, "res://assets/sprites/imagenes_de_cartas/esqueleto.jpg")
	
	user.availableCards[carta_elfo] = 3
	user.availableCards[carta_esqueleto] = 3
	
	# 3. Ejércitos
	var mazo_rapido = _generar_ejercito_prueba("Mazo Rápido", [carta_elfo, carta_esqueleto])
	user.userArmys.append(mazo_rapido)
	user.userArmys[0].isActive = true
	
	return user

func _generar_mapa_prueba(nombre: String, descripcion: String) -> MapRes:
	var mapa = MapRes.new()
	mapa.name = nombre
	mapa.desc = descripcion
	mapa.tamX = randi_range(8, 12)
	mapa.tamY = randi_range(6, 9)
	
	for y in range(mapa.tamY):
		var fila: Array[TileRes] = []
		for x in range(mapa.tamX):
			var tile = TileRes.new()
			var tile_type = TileTypeRes.new()
			tile_type.texture = _get_random_texture("res://assets/tiles/EverHex-Forest Lite/Sky/blue")
			tile.type = tile_type
			fila.append(tile)
		mapa.mapData.append(fila)
		
	return mapa

func _generar_carta_prueba(nombre: String, descripcion: String, peso: int, ruta_img: String) -> CardRes:
	var carta = CardRes.new()
	carta.name = nombre
	carta.desc = descripcion
	carta.weight = peso
	
	if not ruta_img.is_empty():
		var tex = load(ruta_img) as Texture2D
		if tex:
			carta.img = tex
			
	return carta

func _generar_ejercito_prueba(nombre: String, cartas_base: Array[CardRes]) -> ArmyRes:
	var ejercito = ArmyRes.new()
	ejercito.nom = nombre
	
	# Creamos agrupaciones correctas en base a lo que espera ArmyRes y creacio_exercits.gd
	for carta in cartas_base:
		var grupo = CardArmyGroup.new()
		grupo.cardType = carta
		grupo.n = 1
		ejercito.agrupations.append(grupo)
		
	return ejercito

func _get_random_texture(folder_path: String) -> Texture2D:
	var dir = DirAccess.open(folder_path)
	if not dir: 
		return null
		
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import"):
			if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				files.append(folder_path + "/" + file_name)
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	if files.is_empty(): 
		return null
		
	return load(files[randi() % files.size()]) as Texture2D
