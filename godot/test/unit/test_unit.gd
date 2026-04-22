extends GutTest

var _gr : GameResources

func before_all():
	self._gr = GameManager.get_game_resources()
	
	
func test_getters() -> void:
	var atacker := UnitGame.new(_gr.cards[0]) #mele
	assert_eq(atacker.max_hp, atacker._cardRes.hp)


## Comprueba el calculo del daño de una unidad
func test_damage() -> void:
	var atacker := UnitGame.new(_gr.cards[0]) #mele
	var defender := UnitGame.new(_gr.cards[1]) #arquero
		
	var currentHP := defender.hp
	
	var h := atacker.get_available_habilities()[0]
	
	defender.recieve_attack(h.value, h.attackType)
	
	assert_lt(defender.hp, currentHP)
	
