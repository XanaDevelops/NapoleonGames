@tool
class_name PackGameRes
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	print("Pasando .tres a GameResources, despues guarda")
	
	var gr := GameResources.new()

	
