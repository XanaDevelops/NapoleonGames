class_name TestMapGame
extends GutTest

const map_scene: String = "res://scenes/ingame/ingame_map.tscn"

func test_visualizer() -> void:
	var map := create_test_map()
	GameManager._gameMap = map
	var prev_add_target = gut.add_children_to
	gut.add_children_to = get_tree().get_root()
	var scene := preload(map_scene)
	var instance := scene.instantiate()
	add_child_autoqfree(instance)

	await wait_until(func ():
		return instance.is_inside_tree(), 5)
	# allow a short time for the engine to paint the scene so it's visible
	await wait_seconds(gut.paint_after)

	# Pausa antes del teardown para permitir inspección/interacción
	gut.pause_before_teardown()

	pass_test("ok, check UI")
	gut.add_children_to = prev_add_target

func create_test_map() -> MapGame:
	var map_res = MapRes.new()
	map_res.name = "Test Map"
	map_res.desc = "Mapa de prueba"
	map_res.tamX = 23
	map_res.tamY = 11
	map_res.deployHeight=2
	
	
	for y in range(map_res.tamY):
		var row: Array = []
		for x in range(map_res.tamX):
			var tile_res = TileRes.new()
			tile_res.height = 0
			
			var tile_type = TileTypeRes.new()
			tile_type.name = "GrassLand"
			tile_type.desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ac consectetur arcu. Mauris ullamcorper efficitur mollis. Quisque posuere non urna dignissim malesuada. Etiam molestie a enim eu faucibus. Sed est nunc, tincidunt in condimentum a, commodo ac lorem. Quisque tincidunt sapien quis porta malesuada. Etiam imperdiet, purus nec efficitur aliquet, tortor nibh faucibus lectus, id fringilla neque metus vitae libero. Curabitur in diam sit amet augue interdum rhoncus. Donec et massa elit. Nulla eu lobortis purus. Mauris fringilla fermentum nibh, eu faucibus odio volutpat quis. Donec efficitur, dui vel pharetra pretium, neque eros faucibus augue, id scelerisque erat lacus quis massa. Nunc mollis sed sem ut elementum. Aliquam mi ipsum, sodales in cursus a, lobortis a sapien. Integer dapibus, mauris non feugiat mattis, urna ligula convallis libero, et varius eros ligula a nulla. Pellentesque sagittis lectus a tristique maximus.
Vestibulum lacinia dapibus justo. Donec vitae mauris lacinia, porta orci nec, facilisis velit. Nullam lobortis urna eu nisi cursus, non fringilla est consequat. In commodo, sapien at porta eleifend, odio ipsum fermentum ex, ut commodo ligula odio et dolor. Ut faucibus feugiat vehicula. Vivamus ut turpis at orci posuere euismod eu vel purus. Aenean turpis velit, consectetur sed ultricies quis, vestibulum ac odio. Nunc ac ipsum pharetra, tincidunt urna eget, consequat sem. Aenean scelerisque augue consequat, sodales leo et, faucibus nisi. Curabitur sagittis risus eu ligula mollis, non sollicitudin eros feugiat. Aliquam elementum tortor sed orci molestie, sit amet luctus elit pulvinar. Mauris id congue velit. Cras et est eros. In ut augue viverra, sagittis eros sed, rutrum sem."
			tile_type.texture = get_random_tile_texture("res://assets/tiles/EverHex-Forest Lite/Forest")
			#tile_type.mods= Array[TileTypeRes]
			tile_res.type = tile_type
			row.append(tile_res)
		
		map_res.mapData.push_back(row)
	
	var map = MapGame.new(map_res)
	
	for y in range(map_res.tamY):
		for x in range(map_res.tamX):
			if randi() % 2 == 0:
				var card_res = CardRes.new()
				card_res.name = "Warrior"
				card_res.hp = 10
				card_res.desc = "Donec ut enim molestie, auctor risus at, ultrices arcu. Praesent blandit id ipsum ac volutpat. Nam pretium diam augue, ut condimentum massa imperdiet at. Praesent id vulputate justo, at porta ex. Ut et ultrices arcu, ac dictum nulla. Integer feugiat nulla justo, in tristique mi elementum nec. Maecenas semper feugiat turpis sit amet aliquet. Duis sed semper turpis, nec sodales risus. Mauris fermentum ligula at tortor congue porta. Curabitur interdum tellus sed neque tristique, in dictum metus gravida. Integer mollis eu lacus in maximus."
				card_res.img = get_unit_texture("res://assets/tiles/Legacy-Fantasy - High Forest 2.0/Legacy-Fantasy - High Forest 2.3/Character/Idle/Idle-Sheet.png")
				card_res.portrait=  get_unit_texture("res://assets/tiles/Legacy-Fantasy - High Forest 2.0/Legacy-Fantasy - High Forest 2.3/Character/Idle/Idle-Sheet.png")
				card_res.dodge = randi_range(10, 100)
				card_res.mana= randi_range(2, 100)
				card_res.speed= randi_range(10, 80)
				card_res.habilities = generate_habilities()
				card_res.resistances= generate_resistances()
				var unit = UnitGame.new(card_res)
				unit._currentAlterStates = generate_alter_states()
				map.get_tile_at(Vector2i(x, y)).set_unit(unit)
	
	return map
func generate_alter_states() -> Dictionary[AlterStateRes, int]:
	var result: Dictionary[AlterStateRes, int] = {}
	var count = randi_range(3, 8)
	
	var stat_names: Array[StringName] = [&"defense", &"speed", &"attack", &"hp", &"mana"]
	
	for i in range(count):
		var state = AlterStateRes.new()
		
		var stat = StatData.new()
		stat.name = stat_names[randi() % stat_names.size()]
		stat.isPercent = randi() % 2 == 0
		stat.desc = "Modificador de %s" % stat.name
		
		state.stat = stat
		state.value = randf_range(-0.3, 0.5) if stat.isPercent else randf_range(-20.0, 30.0)
		state.hitP = 1.0
		state.duration = randi_range(1, 4)
		state.objectiu = HabilityRes.HAB_DEST.SELF
		
		# El int del diccionario son los turnos restantes (entre 1 y duration)
		var turns_remaining = randi_range(1, state.duration)
		result[state] = turns_remaining
	
	return result
func generate_resistances() -> Dictionary[AttackType, int]:
	var result: Dictionary[AttackType, int] = {}
	
	var attack_names: Array[StringName] = ["Fuego", "Agua", "Tierra", "Aire", "Fisico", "Magico"]
	
	var count = randi_range(4, 10)
	
	
	for i in range(count):
		var attack_type = AttackType.new()
		attack_type.name = attack_names[i % attack_names.size()]
		result[attack_type] = randi_range(-20, 50)
	
	return result
func generate_habilities() -> Array[HabilityRes]:
	var result: Array[HabilityRes] = []
	var count = randi_range(3, 10)
	
	var names = ["Golpe fuerte", "Curación", "Escudo", "Flecha", "Maldición", "Teletransporte"]
	var descs = ["Ataca a un enemigo cercano", "Restaura vida a un aliado", 
				 "Aumenta la defensa", "Dispara a distancia", 
				 "Reduce las estadísticas del enemigo", "Se mueve a cualquier casilla"]
	var objectives = [
		HabilityRes.HAB_DEST.SINGLE_ENEMY,
		HabilityRes.HAB_DEST.MULTI_ENEMY,
		HabilityRes.HAB_DEST.SINGLE_ALLY,
		HabilityRes.HAB_DEST.SELF,
		HabilityRes.HAB_DEST.EVERYONE,
		HabilityRes.HAB_DEST.SINGLE_ANY
	]
	
	for i in range(count):
		var hab = HabilityRes.new()
		var idx = randi() % names.size()
		
		hab.name       = names[idx]
		hab.desc       = descs[idx]
		hab.objective  = objectives[randi() % objectives.size()]
		hab.manaCost   = randi_range(0, 50)
		hab.radius     = randi_range(1, 5)
		hab.cooldown   = randi_range(1, 4)
		hab.duration   = randi_range(0, 3)
		hab.isPassive  = randi() % 4 == 0  # 25% de probabilidad de ser pasiva
		hab.value      = randf_range(5.0, 50.0)
		
		result.append(hab)
	
	return result
func get_unit_texture(sheet_path: String) -> Texture2D:
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
	


func get_random_tile_texture(folder_path: String) -> Texture2D:
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
