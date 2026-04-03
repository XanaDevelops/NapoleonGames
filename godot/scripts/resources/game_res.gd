
## Recurso base del juego ([GameResource])[br]
##
## Clase base para agrupar recursos personalizados en el editor.[br]
##
@abstract
class_name GameResource
extends Resource

@export var uid : int


func compare(res: GameResource) -> bool:
	return self.get_script() == res.get_script() and self.uid == res.uid
