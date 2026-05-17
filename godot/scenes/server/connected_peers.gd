extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Online.on_peer_connected.connect(_add_peer)
	Online.on_peer_disconnected.connect(_del_peer)
	
	
func _add_peer(pid: int) -> void:
	var label := Label.new()
	label.text = str(pid)
	self.add_child.call_deferred(label)
	
func _del_peer(pid: int) -> void:
	for l: Label in get_children():
		if l.text == str(pid):
			remove_child.call_deferred(l)
			break
