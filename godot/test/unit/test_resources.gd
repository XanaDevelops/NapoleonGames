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
var _all_stats: AllStatsRes
var _metadata: MetadataRes
var _map: MapRes

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
	army.agrupations = {cardMele: 1}

	# Crear usuario
	var userRes := UserRes.new()
	userRes.name = "Test User"
	userRes.username = "testuser666"
	userRes.friends = []
	userRes.avariableCards = [cardMele]
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

	# Expandir ejército con la carta a distancia
	army.agrupations[cardRanged] = 2

	# Añadir la carta a usuario
	userRes.avariableCards.append(cardRanged)

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

	# Conjunto de estadísticas
	var all_stats := AllStatsRes.new()
	all_stats.stats = [stat]

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

	# Exponer nuevas referencias
	self._tile_mod = tile_mod
	self._tile_type = tile_type
	self._tile = tile
	self._all_stats = all_stats
	self._metadata = metadata
	self._map = map

	# Guardar recursos de mapa y casillas
	ResourceSaver.save(tile_mod, _folder + "tile_mod.tres")
	ResourceSaver.save(tile_type, _folder + "tile_type.tres")
	ResourceSaver.save(tile, _folder + "tile.tres")
	ResourceSaver.save(all_stats, _folder + "all_stats.tres")
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
	var all_stats_loaded := ResourceLoader.load(_folder + "all_stats.tres")
	var metadata_loaded := ResourceLoader.load(_folder + "metadata.tres")
	var map_loaded := ResourceLoader.load(_folder + "map.tres")

	assert_eq(tile_type_loaded.name, self._tile_type.name)
	assert_eq(tile_mod_loaded.value, self._tile_mod.value)
	assert_eq(tile_loaded.height, self._tile.height)
	assert_eq(all_stats_loaded.stats.size(), self._all_stats.stats.size())
	assert_eq(metadata_loaded.version, self._metadata.version)
	assert_eq(map_loaded.name, self._map.name)
