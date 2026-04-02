class_name TestMapGame
extends Node
static func create_test_map() -> MapGame:
    var map_res = MapRes.new()
    map_res.name = "Test Map"
    map_res.desc = "Mapa de prueba"
    map_res.tamX = 5
    map_res.tamY = 5
    
    for y in range(map_res.tamX):
        var row: Array = []
        for x in range(map_res.tamY):
            var tile_res = TileRes.new()
            tile_res.height = 0
            
            var tile_type = TileTypeRes.new()
            tile_type.name = "GrassLand"
            tile_type.desc = "Terrain de prueba"
            tile_type.texture = get_random_tile_texture("res://assets/tiles/EverHex-Forest Lite/Sky/blue")
            tile_res.type = tile_type
            row.append(tile_res)
        
        map_res.mapData.push_back(row)
    
    var map = MapGame.new(map_res)
    
    for y in range(map_res.tamX):
        for x in range(map_res.tamY):
            if randi() % 2 == 0:
                var card_res = CardRes.new()
                card_res.name = "Warrior"
                card_res.hp = 10
                card_res.img = get_unit_texture("res://assets/tiles/Legacy-Fantasy - High Forest 2.0/Legacy-Fantasy - High Forest 2.3/Character/Idle/Idle-Sheet.png")
                
                var unit = UnitGame.new(card_res)
                map.get_tile_at(x, y).set_unit(unit)
    
    return map

static func get_unit_texture(sheet_path: String) -> Texture2D:
    var texture = load(sheet_path) as Texture2D
    if texture == null:
        push_error("No se puede cargar: " + sheet_path)
        return null
    
    var sprite_width = 64   # 256 / 4 sprites
    var sprite_height = 80
    var index = randi() % 4
    
    var atlas = AtlasTexture.new()
    atlas.atlas = texture
    atlas.region = Rect2(index * sprite_width, 0, sprite_width, sprite_height)
    return atlas
    


static func get_random_tile_texture(folder_path: String) -> Texture2D:
    var dir = DirAccess.open(folder_path)
    if dir == null:
        push_error("No se puede abrir la carpeta: " + folder_path)
        return null
    
    var files: Array = []
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
            files.append(folder_path + "/" + file_name)
        file_name = dir.get_next()
    dir.list_dir_end()
    
    if files.is_empty():
        push_error("No hay texturas en: " + folder_path)
        return null
    
    var random_file = files[randi() % files.size()]
    return load(random_file)
