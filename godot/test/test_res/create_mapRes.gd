@tool
extends EditorScript

func _run() -> void:
	var map_res = MapRes.new()
	map_res.name = "ForestMap"
	map_res.desc = "Mapa de bosque"
	map_res.tamX = 23
	map_res.tamY = 10
	map_res.deployHeight = 2
	map_res.uid = 2
	
	var grass = _create_tile_type("Grass", "Pradera abierta", 1, "res://assets/tiles/EverHex-Forest Lite/Forest/1.png", 10)
	var forest = _create_tile_type("Tree", "Bosque ligero", 2, "res://assets/tiles/EverHex-Forest Lite/Forest/7.png", 11)
	var path = _create_tile_type("Path", "Camino de tierra", 1, "res://assets/tiles/EverHex-Forest Lite/Forest/168.png", 12)
	var forest2= _create_tile_type("Tree", "Bosque denso", 2, "res://assets/tiles/EverHex-Forest Lite/Forest/14.png", 13)
	# Layout 23x10
	var layout = [
		[0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,0],
		[0,1,0,1,0,3,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0],
		[1,1,0,0,0,2,1,0,1,2,0,0,0,1,1,0,0,3,1,0,1,2,0],
		[0,0,0,1,2,2,0,0,0,2,2,1,0,0,0,1,2,2,0,3,0,2,1],
		[0,1,0,0,0,2,0,3,0,2,0,0,0,1,0,0,0,2,0,0,3,2,0],
		[0,1,0,0,0,2,0,0,0,2,0,0,0,1,0,0,0,2,0,0,0,2,0],
		[0,0,0,1,2,2,0,0,0,2,2,1,0,0,0,1,2,2,0,0,0,2,1],
		[1,1,0,0,0,2,1,0,1,2,0,0,0,1,1,0,0,2,1,0,1,2,0],
		[0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0],
		[0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,1,0],
	]
	
	var types = [grass, forest, path, forest2]
	var start_uid := 1000
	for y in range(map_res.tamY):
		var row: Array[TileRes] = []
		for x in range(map_res.tamX):
			var tile := TileRes.new()
			tile.type = types[layout[y][x]]
			tile.height = 2 if layout[y][x] == 2 else 0
			tile.uid = start_uid
			start_uid+=1
			row.append(tile)
		map_res.mapData.append(row)
	
	var err = ResourceSaver.save(map_res, "res://resources/maps/0002.tres")
	if err == OK:
		print("Mapa guardado correctamente")
	else:
		print("Error al guardar: ", err)

func _create_tile_type(name: String, desc: String, cost: int, texture_path: String, uid: int) -> TileTypeRes:
	var tile_type := TileTypeRes.new()
	tile_type.name = name
	tile_type.desc = desc
	tile_type.cost = cost
	tile_type.uid = uid
	if ResourceLoader.exists(texture_path):
		tile_type.texture = load(texture_path)
	return tile_type
