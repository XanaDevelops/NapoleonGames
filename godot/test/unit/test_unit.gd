extends GutTest

var _gr : GameResources
var map : MapGame


func before_all():
	self._gr = GameResources.load_from("res://test/test_res/all_test_resources.tres")
	self.map = MapGame.new(TestHabilities.gen_test_map())
	var tm := TurnManager.new()
	GameManager.register_turn_manager(tm)
	GameManager.game_config = GameConfig.new(null, null, self.map._mapRes, null, null)
	tm.set_map(self.map)
	
func test_getters() -> void:
	var atacker := UnitGame.new(_gr.cards[0], null) #mele
	assert_eq(atacker.max_hp, atacker._cardRes.hp)


## Comprueba el calculo del daño de una unidad
func test_damage() -> void:
	var atacker := UnitGame.new(_gr.cards[0], null) #mele
	map.place_unit(atacker, Vector2i(0, 0))
	var defender := UnitGame.new(_gr.cards[1], null) #arquero
	map.place_unit(defender, Vector2i(0, 0))
	var currentHP := defender.hp
	
	var h := atacker.get_all_habilities()[0]
	
	defender.recieve_attack(h.value, h.attackType)
	
	assert_lt(defender.hp, currentHP)
	
