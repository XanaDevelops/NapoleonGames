extends GutTest

var _folder:= "res://test/res/"
var _card_type: CardTypeRes
var _stat: StatData
var _attack_type: AttackType
var _hab1: HabilityRes
var _card_mele: CardRes
var _army: ArmyRes
var _user: UserRes
var _hab_range: HabilityRes
var _card_ranged: CardRes
var _tile_type: TileTypeRes
var _tile_mod: TileModRes
var _tile: TileRes
var _metadata: MetadataRes
var _map: MapRes
var _tile_stone_type: TileTypeRes
var _tile_stone: TileRes

## Crea los recursos para los tests
func before_all():
	# Crear tipo de carta
	var cardType := CardTypeRes.new()
	cardType.name = "baseType"
	cardType.desc = "Tipo base para tests"

	# Crear estadística y tipo de ataque para la habilidad
	var stat := StatData.new()
	stat.name = "attack"
	stat.desc = "Daño base"

	var attack_type := AttackType.new()
	attack_type.name = "physical"

	# Crear habilidad
	var hab1 := HabilityRes.new()
	hab1.value = 5.0
	hab1.stat = stat
	hab1.attackType = attack_type
	hab1.manaCost = 1
	hab1.duration = 0
	hab1.isPassive = false

	# Crear carta melee
	var cardMele := CardRes.new()
	cardMele.name = "meleCard"
	cardMele.desc = "lorem ipsum"
	cardMele.types = [cardType]
	cardMele.hp = 10
	cardMele.mana = 0
	cardMele.speed = 2
	cardMele.dodge = 0.0
	cardMele.img = null
	cardMele.resistances = {}
	cardMele.habilities = [hab1]

	# Crear ejército
	var army := ArmyRes.new()
	army.nom = "Test Army"
	army.isActive = true
	# agrupations ahora es Array[CardArmyGroup]
	var group1 := CardArmyGroup.new()
	group1.cardType = cardMele
	group1.n = 1
	army.agrupations = [group1]

	# Crear usuario
	var userRes := UserRes.new()
	userRes.name = "Test User"
	userRes.username = "testuser666"
	userRes.friends = []
	# avariableCards ahora es Dictionary[CardRes, int]
	userRes.avariableCards = {cardMele: 1}
	userRes.userArmys = [army]
	userRes.avariableMaps = []

	# Exponer recursos para otros tests
	self._card_type = cardType
	self._stat = stat
	self._attack_type = attack_type
	self._hab1 = hab1
	self._card_mele = cardMele
	self._army = army
	self._user = userRes

	# Crear habilidad de rango
	var hab_range := HabilityRes.new()
	hab_range.value = 8.0
	hab_range.stat = stat
	hab_range.attackType = attack_type
	hab_range.radius = 3
	hab_range.manaCost = 2
	hab_range.duration = 0
	hab_range.isPassive = false

	# Crear carta a distancia
	var cardRanged := CardRes.new()
	cardRanged.name = "rangedCard"
	cardRanged.desc = "arquero"
	cardRanged.types = [cardType]
	cardRanged.hp = 6
	cardRanged.mana = 0
	cardRanged.speed = 3
	cardRanged.dodge = 0.05
	cardRanged.img = null
	cardRanged.resistances = {}
	cardRanged.habilities = [hab_range]

	# Expandir ejército con la carta a distancia (añadir como CardArmyGroup)
	var group2 := CardArmyGroup.new()
	group2.cardType = cardRanged
	group2.n = 2
	army.agrupations.append(group2)

	# Añadir la carta a usuario
	# avariableCards es un Dictionary[CardRes, int], incrementar o crear entrada
	if userRes.avariableCards.has(cardRanged):
		userRes.avariableCards[cardRanged] += 1
	else:
		userRes.avariableCards[cardRanged] = 1

	# Exponer nuevas referencias
	self._hab_range = hab_range
	self._card_ranged = cardRanged

	# --- Recursos de mapa y casillas ---

	# Modificador de casilla
	var tile_mod := TileModRes.new()
	tile_mod.value = 1.5
	tile_mod.stat = stat
	tile_mod.affectType = cardType

	# Tipo de casilla
	var tile_type := TileTypeRes.new()
	tile_type.name = "grass"
	tile_type.desc = "Casilla de hierba"
	tile_type.mods = [tile_mod]

	# Casilla
	var tile := TileRes.new()
	tile.height = 0
	tile.type = tile_type

	# Metadatos
	var metadata := MetadataRes.new()
	metadata.version = 1
	metadata.lastModified = 0

	# Mapa
	var map := MapRes.new()
	map.name = "test_map"
	map.desc = "Mapa de prueba"
	map.tamX = 10
	map.tamY = 10

	# Crear tipo de casilla piedra y su tile
	var tile_type_stone := TileTypeRes.new()
	tile_type_stone.name = "stone"
	tile_type_stone.desc = "Casilla de piedra"

	var tile_stone := TileRes.new()
	tile_stone.height = 0
	tile_stone.type = tile_type_stone

	# Rellenar mapData 10x10 con el patrón ("#" = grass, "X" = stone)
	var pattern := [
		"XXXXXXXXXX",
		"X########X",
		"X#X####X#X",
		"X#X####X#X",
		"X########X",
		"X#X####X#X",
		"X#XXXXXX#X",
		"X########X",
		"X########X",
		"XXXXXXXXXX",
		]

	# Inicializar fondo con piedra y luego pintar pasto donde corresponda
	map.mapData = []
	for y in pattern.size():
		var row := []
		for x in pattern[y].length():
			var ch : String = pattern[y][x]
			var cell := TileRes.new()
			cell.height = 0
			if ch == "X":
				cell.type = tile_type_stone
			else:
				cell.type = tile_type
			row.append(cell)
		map.mapData.append(row)

	# Exponer piedra
	self._tile_stone_type = tile_type_stone
	self._tile_stone = tile_stone

	# Exponer nuevas referencias
	self._tile_mod = tile_mod
	self._tile_type = tile_type
	self._tile = tile
	self._metadata = metadata
	self._map = map

	# Guardar recursos de mapa y casillas
	ResourceSaver.save(tile_mod, _folder + "tile_mod.tres")
	ResourceSaver.save(tile_type, _folder + "tile_type.tres")
	ResourceSaver.save(tile, _folder + "tile.tres")
	ResourceSaver.save(tile_type_stone, _folder + "tile_type_stone.tres")
	ResourceSaver.save(metadata, _folder + "metadata.tres")
	ResourceSaver.save(map, _folder + "map.tres")

	# Guardar recursos en disco (res://test/res/)
	ResourceSaver.save(cardType, _folder + "card_type.tres")
	ResourceSaver.save(stat, _folder + "stat_attack.tres")
	ResourceSaver.save(attack_type, _folder + "attack_type.tres")
	ResourceSaver.save(hab1, _folder + "hab_mele.tres")
	ResourceSaver.save(hab_range, _folder + "hab_range.tres")
	ResourceSaver.save(cardMele, _folder + "card_mele.tres")
	ResourceSaver.save(cardRanged, _folder + "card_ranged.tres")
	ResourceSaver.save(army, _folder + "army.tres")
	ResourceSaver.save(userRes, _folder + "user.tres")

	# Crear y guardar recurso agregado que contiene todas las colecciones
	var all_res := GameResources.new()
	all_res.metadata = metadata
	all_res.users = [userRes]
	all_res.card_types = [cardType]
	all_res.cards = [cardMele, cardRanged]
	all_res.attack_types = [attack_type]
	all_res.habilities = [hab1, hab_range]
	all_res.tile_mods = [tile_mod]
	all_res.tile_types = [tile_type]
	all_res.tiles = [tile]
	all_res.maps = [map]
	all_res.armies = [army]
	all_res.stats = [stat]
	all_res.alter_states = []

	ResourceSaver.save(all_res, _folder + "all_game_res.tres")


func test_saved_resources_load_and_compare():
	# Cargar recursos guardados
	var card_mele_loaded := ResourceLoader.load(_folder + "card_mele.tres")
	var card_ranged_loaded := ResourceLoader.load(_folder + "card_ranged.tres")
	var hab_range_loaded := ResourceLoader.load(_folder + "hab_range.tres")
	var user_loaded := ResourceLoader.load(_folder + "user.tres")

	# Comparar valores básicos de la carta melee
	assert_eq(card_mele_loaded.name, self._card_mele.name)
	assert_eq(card_mele_loaded.hp, self._card_mele.hp)
	assert_eq(card_mele_loaded.types.size(), self._card_mele.types.size())

	# Comparar carta a distancia y su habilidad
	assert_eq(card_ranged_loaded.name, self._card_ranged.name)
	assert_eq(card_ranged_loaded.habilities.size(), self._card_ranged.habilities.size())
	assert_eq(hab_range_loaded.radius, self._hab_range.radius)
	assert_eq(hab_range_loaded.value, self._hab_range.value)

	# Comparar usuario y sus cartas
	assert_eq(user_loaded.username, self._user.username)
	assert_eq(user_loaded.avariableCards.size(), self._user.avariableCards.size())

	# Cargar y comparar recursos de mapa y casillas
	var tile_mod_loaded := ResourceLoader.load(_folder + "tile_mod.tres")
	var tile_type_loaded := ResourceLoader.load(_folder + "tile_type.tres")
	var tile_loaded := ResourceLoader.load(_folder + "tile.tres")
	var metadata_loaded := ResourceLoader.load(_folder + "metadata.tres")
	var map_loaded := ResourceLoader.load(_folder + "map.tres")

	assert_eq(tile_type_loaded.name, self._tile_type.name)
	assert_eq(tile_mod_loaded.value, self._tile_mod.value)
	assert_eq(tile_loaded.height, self._tile.height)
	assert_eq(metadata_loaded.version, self._metadata.version)
	assert_eq(map_loaded.name, self._map.name)

	# Cargar y comprobar el recurso agregado que contiene todas las colecciones
	var all_game_loaded := ResourceLoader.load(_folder + "all_game_res.tres")
	assert_ne(all_game_loaded, null)
	assert_eq(all_game_loaded.metadata.version, self._metadata.version)
	assert_eq(all_game_loaded.users.size(), 1)
	assert_eq(all_game_loaded.cards.size(), 2)
	assert_eq(all_game_loaded.habilities.size(), 2)
	assert_eq(all_game_loaded.tile_types.size(), 1)
	assert_eq(all_game_loaded.maps.size(), 1)

	# Comprobar algunos valores del mapa cargado (patrón)
	# esquina superior izquierda (0,0) debe ser piedra
	assert_eq(map_loaded.mapData[0][0].type.name, self._tile_stone_type.name)
	# posición (1,1) interior debe ser hierba
	assert_eq(map_loaded.mapData[1][1].type.name, self._tile_type.name)


func test_io_funcs() -> void:
	# Guardar una copia del recurso agregado `all_game_res.tres` en un nuevo path
	var save_path := _folder + "io_test_all_game_res.tres"
	var original := GameResources.load_from(_folder + "all_game_res.tres")
	assert_ne(original, null)

	# Intentar guardar y comprobar que el save devuelve OK usando la función de la clase
	var err := original.save_to(save_path)
	assert_eq(err, OK)

	# Cargar la copia guardada usando la función de la clase
	var loaded := GameResources.load_from(save_path)
	assert_ne(loaded, null)

	assert_eq(loaded.metadata.version, original.metadata.version)
	assert_eq(loaded.users.size(), original.users.size())
	assert_eq(loaded.cards.size(), original.cards.size())

	# Comprobar un valor interno concreto
	assert_eq(loaded.users[0].username, self._user.username)
