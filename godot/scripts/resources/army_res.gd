
## Ejército ([ArmyRes])[br]
##
## Recurso que representa un ejército de cartas.[br]
##
## [br]
##
## Atributos:[br]
## - nom: Nombre del ejército.[br]
## - isActive: Indica si está activo.[br]
## - agrupations: Agrupaciones de cartas y cantidad (Dictionary[[CardRes], int]).[br]
##
class_name ArmyRes
extends GameResource

const MAX_SIZE := 20


## Nombre del ejército (identificador)
@export var nom: StringName
## Indica si está activo	
@export var isActive:= false
## Agrupaciones de cartas y cantidad (Dictionary[[CardRes], int])
@export var agrupations: Array[CardArmyGroup] = []

func get_weight() -> int:
	return agrupations.map(func(elem: CardArmyGroup): return elem.get_weight()) \
						.reduce(func(el, ac): return el+ac, 0)

func clonar() -> ArmyRes:
	var copia = ArmyRes.new()
	copia.nom = self.nom
	copia.isActive = self.isActive
	
	for grupo in self.agrupations:
		var nuevo_grupo = CardArmyGroup.new()
		nuevo_grupo.cardType = grupo.cardType 
		nuevo_grupo.n = grupo.n              
		copia.agrupations.append(nuevo_grupo)
		
	return copia
