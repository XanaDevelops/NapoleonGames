
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

	await wait_until(func():
		return instance.is_inside_tree(), 5)
	await wait_seconds(gut.paint_after)
	autoqfree(instance._hab_manager)

	gut.pause_before_teardown()
	pass_test("ok, check UI")
	gut.add_children_to = prev_add_target


func test_hability_applies_to_bars() -> void:
	var gr := GameResources.load_from()
	var map := create_test_map()
	GameManager._gameMap = map
	GameManager._user_a = gr.users[0]
	GameManager._user_b = gr.users[1]
	GameManager._army_a = gr.users[0].obtener_ejercito_activo()
	GameManager._army_b = gr.users[1].obtener_ejercito_activo()

	# Usar game_scene.tscn que incluye TurnManager
	var prev_add_target = gut.add_children_to
	gut.add_children_to = get_tree().get_root()
	var instance := preload("res://scenes/ingame/game_scene.tscn").instantiate() as TurnManager
	instance.turn_order = [gr.users[0], gr.users[1]]
	instance.turn_number = 0
	add_child_autoqfree(instance)

	await wait_until(func(): return instance.is_inside_tree(), 5)
	await wait_seconds(gut.paint_after)
	var ingame_map = instance.get_node("IngameMap")
	autoqfree(ingame_map._hab_manager)

	var unit_info = instance.get_node("IngameMap/VBoxContainer/CardsPanel/MarginContainer/TabContainer/UnitInfo")
	assert_not_null(unit_info, "UnitInfo debe existir")

	# Crear unidades de test con CardRes válido
	var card_attacker = CardRes.new()
	card_attacker.name = "Atacante"
	card_attacker.hp = 100
	card_attacker.mana = 50
	card_attacker.speed = 3
	card_attacker.dodge = 10.0
	card_attacker.habilities = [_create_physical_attack()] as Array[HabilityRes]
	card_attacker.resistances = {} as Dictionary[AttackType, int]

	var card_target = CardRes.new()
	card_target.name = "Objetivo"
	card_target.hp = 80
	card_target.mana = 40
	card_target.speed = 2
	card_target.dodge = 5.0
	card_target.habilities = [] as Array[HabilityRes]
	card_target.resistances = {} as Dictionary[AttackType, int]

	var attacker = UnitGame.new(card_attacker, gr.users[0])
	var target = UnitGame.new(card_target, gr.users[1])

	# Colocar unidades en el mapa
	var attacker_pos = Vector2i(5, 5)
	var target_pos = Vector2i(6, 5)
	map.get_tile_at(attacker_pos).set_unit(attacker)
	map.get_tile_at(target_pos).set_unit(target)

	# ── Test A: Observar target y verificar HP inicial ──
	unit_info.observe(target)
	await wait_physics_frames(2)

	var hp_bar: ProgressBar = unit_info.current_health
	assert_eq(int(hp_bar.value), 80, "HP inicial debe ser 80")

	# ── Test B: Daño directo baja HP ──
	var hp_before = target.hp
	target.hp -= 20
	await wait_physics_frames(2)

	assert_eq(target.hp, hp_before - 20, "HP debe bajar tras daño")
	assert_eq(int(hp_bar.value), hp_before - 20, "Barra HP debe reflejar daño")

	# ── Test C: Curación sube HP ──
	var hp_after_damage = target.hp
	target.hp += 10
	await wait_physics_frames(2)

	assert_eq(target.hp, hp_after_damage + 10, "HP debe subir tras curación")
	assert_eq(int(hp_bar.value), hp_after_damage + 10, "Barra HP debe reflejar curación")

	# ── Test D: Observar atacante y verificar maná ──
	unit_info.observe(attacker)
	await wait_physics_frames(2)

	var mana_bar: ProgressBar = unit_info.current_mana
	assert_eq(int(mana_bar.value), 50, "Mana inicial debe ser 50")

	# ── Test E: Consumo de maná ──
	attacker.mana -= 25
	await wait_physics_frames(2)

	assert_eq(attacker.mana, 25, "Mana debe bajar")
	assert_eq(int(mana_bar.value), 25, "Barra mana debe reflejar consumo")

	# ── Test F: Cambiar observación a target muestra valores correctos ──
	unit_info.observe(target)
	await wait_physics_frames(2)

	assert_eq(int(hp_bar.value), target.hp, "Barra debe mostrar HP del target")

	gut.pause_before_teardown()
	pass_test("Hability application and bars update correctly")
	gut.add_children_to = prev_add_target

func _create_physical_attack() -> HabilityRes:
	var hab = HabilityRes.new()
	hab.name = "Golpe de espada"
	hab.desc = "Ataque cuerpo a cuerpo con espada"
	#hab.objective = HabilityRes.SEL_ENEMY_FLAG
	hab.objective = HabilityRes.SEL_ALLY_FLAG

	hab.manaCost = 0
	hab.radius = 1
	hab.cooldown = 1
	hab.isPassive = false
	hab.value = 15.0
	hab.alter_states = [] as Array[AlterStateRes]

	hab.stat = StatData.new()
	hab.stat.name = StatData.DEFENSE
	hab.stat.isPercent = false

	hab.attackType = AttackType.new()
	hab.attackType.name = &"Fisico"

	return hab

func _create_magic_attack() -> HabilityRes:
	var hab = HabilityRes.new()
	hab.name = "Bola de fuego"
	hab.desc = "Lanza una bola de fuego al enemigo"
	#hab.objective = HabilityRes.SEL_ENEMY_FLAG
	hab.objective = HabilityRes.SEL_ALLY_FLAG

	hab.manaCost = 25
	hab.radius = 3
	hab.cooldown = 2
	hab.isPassive = false
	hab.value = 30.0
	hab.alter_states = [] as Array[AlterStateRes]

	hab.stat = StatData.new()
	hab.stat.name = StatData.DEFENSE
	hab.stat.isPercent = false

	hab.attackType = AttackType.new()
	hab.attackType.name = &"Magico"

	return hab

func _create_heal() -> HabilityRes:
	var hab = HabilityRes.new()
	hab.name = "Curación menor"
	hab.desc = "Restaura vida a una unidad aliada"
	hab.objective = HabilityRes.SEL_ALLY_FLAG | HabilityRes.SEL_SELF_FLAG
	hab.manaCost = 15
	hab.radius = 2
	hab.cooldown = 2
	hab.isPassive = false
	hab.value = 20.0
	hab.alter_states = [] as Array[AlterStateRes]

	hab.stat = StatData.new()
	hab.stat.name = &"hp"
	hab.stat.isPercent = false

	return hab

func _create_poison() -> AlterStateRes:
	var state = AlterStateRes.new()
	state.stat = StatData.new()
	state.stat.name = &"hp"
	state.stat.isPercent = false
	state.value = -5.0
	state.hitP = 1.0
	state.duration = 3
	state.objectiu = HabilityRes.SEL_ENEMY_FLAG
	return state

func _create_shield_buff() -> AlterStateRes:
	var state = AlterStateRes.new()
	state.stat = StatData.new()
	state.stat.name = StatData.DEFENSE
	state.stat.isPercent = false
	state.value = 10.0
	state.hitP = 1.0
	state.duration = 2
	state.objectiu = HabilityRes.SEL_SELF_FLAG
	return state

func _create_speed_debuff() -> AlterStateRes:
	var state = AlterStateRes.new()
	state.stat = StatData.new()
	state.stat.name = StatData.SPEED
	state.stat.isPercent = false
	state.value = -3.0
	state.hitP = 0.75
	state.duration = 2
	state.objectiu = HabilityRes.SEL_ENEMY_FLAG
	return state



func generate_habilities() -> Array[HabilityRes]:
	var result: Array[HabilityRes] = []

	var basic_attack = _create_physical_attack()
	result.append(basic_attack)

	# Pool de habilidades posibles
	var pool: Array[Callable] = [
		func():
			var h = _create_magic_attack()
			# Variación: añadir veneno
			if randi() % 2 == 0:
				h.name = "Flecha envenenada"
				h.desc = "Dispara una flecha con veneno"
				h.attackType.name = &"Fisico"
				h.manaCost = 10
				h.radius = 2
				h.value = 10.0
				h.alter_states = [_create_poison()] as Array[AlterStateRes]
			return h,
		func():
			return _create_heal(),
		func():
			var h = HabilityRes.new()
			h.name = "Escudo mágico"
			h.desc = "Aumenta la defensa temporalmente"
			h.objective = HabilityRes.SEL_SELF_FLAG
			h.manaCost = 10
			h.radius = 0
			h.cooldown = 3
			h.isPassive = false
			h.value = 0.0
			h.alter_states = [_create_shield_buff()] as Array[AlterStateRes]
			h.stat = null
			return h,
		func():
			var h = HabilityRes.new()
			h.name = "Ralentización"
			h.desc = "Reduce la velocidad del enemigo"
			h.objective = HabilityRes.SEL_ENEMY_FLAG
			h.manaCost = 15
			h.radius = 3
			h.cooldown = 2
			h.isPassive = false
			h.value = 0.0
			h.alter_states = [_create_speed_debuff()] as Array[AlterStateRes]
			h.stat = null
			return h,
		func():
			var h = HabilityRes.new()
			h.name = "Golpe masivo"
			h.desc = "Ataque en área a todos los enemigos cercanos"
			h.objective = HabilityRes.SEL_ENEMY_FLAG | HabilityRes.SEL_MULT_FLAG
			h.manaCost = 30
			h.radius = 2
			h.cooldown = 3
			h.isPassive = false
			h.value = 20.0
			h.alter_states = [] as Array[AlterStateRes]
			h.stat = StatData.new()
			h.stat.name = StatData.DEFENSE
			h.stat.isPercent = false
			h.attackType = AttackType.new()
			h.attackType.name = &"Fisico"
			return h,
	]

	#  habilidades aleatorias del pool
	var count = randi_range(2, 4)
	pool.shuffle()
	for i in range(mini(count, pool.size())):
		result.append(pool[i].call())

	return result


func generate_alter_states() -> Dictionary[AlterStateRes, int]:
	var result: Dictionary[AlterStateRes, int] = {}
	var count = randi_range(0, 3)

	var creators: Array[Callable] = [
		func(): return _create_poison(),
		func(): return _create_shield_buff(),
		func(): return _create_speed_debuff(),
	]

	creators.shuffle()
	for i in range(mini(count, creators.size())):
		var state = creators[i].call()
		result[state] = randi_range(1, state.duration)

	return result


func generate_resistances() -> Dictionary[AttackType, int]:
	var result: Dictionary[AttackType, int] = {}
	var types_data = [
		{name = &"Fisico",  range_min = 0, range_max = 20},
		{name = &"Magico",  range_min = -10, range_max = 30},
		{name = &"Fuego",   range_min = -20, range_max = 25},
		{name = &"Agua",    range_min = -15, range_max = 20},
	]

	# Siempre incluir físico y mágico, los otros son opcionales
	for i in range(types_data.size()):
		if i < 2 or randi() % 2 == 0:
			var attack_type = AttackType.new()
			attack_type.name = types_data[i].name
			result[attack_type] = randi_range(types_data[i].range_min, types_data[i].range_max)

	return result


func create_test_map() -> MapGame:
	var map_res = MapRes.new()
	map_res.name = "Test Map"
	map_res.desc = "Mapa de prueba"
	map_res.tamX = 23
	map_res.tamY = 10
	map_res.deployHeight = 2

	for y in range(map_res.tamY):
		var row: Array = []
		for x in range(map_res.tamX):
			var tile_res = TileRes.new()
			tile_res.height = randi_range(0, 2)

			var tile_type = TileTypeRes.new()
			tile_type.name = ["GrassLand", "Forest", "Mountain", "Plains"][randi() % 4]
			tile_type.desc = "Terreno de tipo %s" % tile_type.name
			tile_type.cost = 1 if tile_type.name == "Plains" else 2
			tile_type.texture = get_random_tile_texture("res://assets/tiles/EverHex-Forest Lite/Forest")
			tile_res.type = tile_type
			row.append(tile_res)

		map_res.mapData.push_back(row)

	var map = MapGame.new(map_res)

	# Colocar unidades con nombres variados
	var unit_templates = [
		{name = "Guerrero",  hp = 100, mana = 20,  speed = 3, dodge = 10.0},
		{name = "Arquero",   hp = 70,  mana = 30,  speed = 4, dodge = 20.0},
		{name = "Mago",      hp = 50,  mana = 80,  speed = 2, dodge = 5.0},
		{name = "Caballero", hp = 120, mana = 15,  speed = 2, dodge = 8.0},
		{name = "Sanador",   hp = 60,  mana = 60,  speed = 3, dodge = 12.0},
	]

	for y in range(map_res.tamY):
		for x in range(map_res.tamX):
			if randi() % 3 == 0:
				var template = unit_templates[randi() % unit_templates.size()]
				var card_res = CardRes.new()
				card_res.name = template.name
				card_res.desc = "Unidad de tipo %s" % template.name
				card_res.hp = template.hp
				card_res.mana = template.mana
				card_res.speed = template.speed
				card_res.dodge = template.dodge
				card_res.img = get_unit_texture("res://assets/tiles/Legacy-Fantasy - High Forest 2.0/Legacy-Fantasy - High Forest 2.3/Character/Idle/Idle-Sheet.png")
				card_res.portrait = get_unit_texture("res://assets/tiles/Legacy-Fantasy - High Forest 2.0/Legacy-Fantasy - High Forest 2.3/Character/Idle/Idle-Sheet.png")
				card_res.habilities = generate_habilities()
				card_res.resistances = generate_resistances()
				var unit = UnitGame.new(card_res, null)
				unit._currentAlterStates = generate_alter_states()
				#map.get_tile_at(Vector2i(x, y)).set_unit(unit)

	return map


func get_unit_texture(sheet_path: String) -> Texture2D:
	var texture = load(sheet_path) as Texture2D
	if texture == null:
		push_error("No se puede cargar: " + sheet_path)
		return null

	var sprite_width = 64
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


func test_bars_react_to_signals() -> void:
	# Crear una unidad simple
	var card = CardRes.new()
	card.name = "Test Unit"
	card.hp = 100
	card.mana = 50
	card.habilities = [] as Array[HabilityRes]
	card.resistances = {} as Dictionary[AttackType, int]
	
	var unit = UnitGame.new(card, null)
	
	# Instanciar escena
	var gr := GameResources.load_from()
	var map := create_test_map()
	GameManager._gameMap = map
	
	var prev_add_target = gut.add_children_to
	gut.add_children_to = get_tree().get_root()
	var instance := preload("res://scenes/ingame/game_scene.tscn").instantiate()  as TurnManager
	instance.turn_order = [gr.users[0], gr.users[1]]
	instance.turn_number = 0
	add_child_autoqfree(instance)
	
	await wait_until(func(): return instance.is_inside_tree(), 5)
	await wait_seconds(gut.paint_after)
	var ingame_map = instance.get_node("IngameMap")
	autoqfree(ingame_map._hab_manager)
	
	var unit_info = instance.get_node("IngameMap/VBoxContainer/CardsPanel/MarginContainer/TabContainer/UnitInfo")
	var hp_bar: ProgressBar = unit_info.current_health
	var mana_bar: ProgressBar = unit_info.current_mana
	
	# Conectar la barra a la unidad
	unit_info.observe(unit)
	await wait_physics_frames(2)
	
	#  Verificar valores iniciales 
	assert_eq(int(hp_bar.value), 100, "HP inicial debe ser 100")
	assert_eq(int(mana_bar.value), 50, "Mana inicial debe ser 50")
	
	#  Bajar HP directamente 
	unit.hp -= 30
	await wait_physics_frames(2)
	assert_eq(int(hp_bar.value), 70, "Barra HP debe mostrar 70")
	
	#  Bajar mana directamente 
	unit.mana -= 20
	await wait_physics_frames(2)
	assert_eq(int(mana_bar.value), 30, "Barra mana debe mostrar 30")
	
	# Subir HP 
	unit.hp += 10
	await wait_physics_frames(2)
	assert_eq(int(hp_bar.value), 80, "Barra HP debe mostrar 80")
	
	#  HP no baja de 0 
	unit.hp = -999
	await wait_physics_frames(2)
	assert_eq(unit.hp, 0, "HP no debe ser negativo")
	assert_eq(int(hp_bar.value), 0, "Barra HP debe mostrar 0")
	
	# Mana no baja de 0 
	unit.mana = -50
	await wait_physics_frames(2)
	assert_eq(unit.mana, 0, "Mana no debe ser negativo")
	assert_eq(int(mana_bar.value), 0, "Barra mana debe mostrar 0")
	
	gut.pause_before_teardown()
	pass_test("Bars react correctly to signal changes")
	gut.add_children_to = prev_add_target
