@tool
extends EditorScript

func _run() -> void:
	var layout := [
		[2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,1,0,0,2,2,0,0],
		[0,0,0,0,0,0,1,0,0,0,1,2,1,0,1,0,1,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,1,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,0,0,0,1,2,1,0,1,0,1,2,2,2,2,2,2],
		[0,0,0,0,0,0,1,1,1,0,1,2,1,0,1,1,1,0,0,0,0,0,0],
		[0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,0,0,0,0,0,2,2,0,0,2,0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	]
	var map_res = MapRes.new()
	map_res.name = "PresentationMap"
	map_res.desc = "Mapa de presentación"
	map_res.tamX = 23
	map_res.tamY = 10
	map_res.deployHeight = 2
	map_res.uid = 3
	
	var grass : TileTypeRes = preload("res://resources/tile_types/0001.tres")
	var forest : TileTypeRes = preload("res://resources/tile_types/0003.tres") 
	var roca : TileTypeRes = preload("res://resources/tile_types/0002.tres")
	# Layout 23x10
	
	
	var types = [grass, roca, forest]
	var start_uid := 2000
	for y in range(map_res.tamY):
		var row: Array[TileRes] = []
		for x in range(map_res.tamX):
			var tile := TileRes.new()
			tile.type = types[layout[y][x]]
			tile.height = 2 if layout[y][x] == 2 else 0
			tile.uid = start_uid
			start_uid+=1
			var name := str(tile.uid).lpad(4, "0") + ".tres"
			ResourceSaver.save(tile, "res://resources/tiles/"+name)
			tile = load("res://resources/tiles/"+name)
			row.append(tile)
		map_res.mapData.append(row)
	
	var err = ResourceSaver.save(map_res, "res://resources/maps/0003.tres")
	if err == OK:
		print("Mapa guardado correctamente")
	else:
		print("Error al guardar: ", err)
