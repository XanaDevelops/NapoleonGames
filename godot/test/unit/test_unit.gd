extends GutTest

var _gr : GameResources

func before_all():
	self._gr = GameResources.load_from()
	
## Comprueba el calculo del daño de una unidad
func test_damage() -> void:
	gut.logger.log("HOLA????????????")
	var atacker := UnitGame.new(_gr.cards[0]) #mele
	var defender := UnitGame.new(_gr.cards[1]) #arquero
		
	var currentHP := defender._currentHealth
	
	var h := atacker.get_avariable_habilities()[0]
	
	defender.recieve_attack(h.value, h.attackType)
	
	assert_lt(defender._currentHealth, currentHP)
	
