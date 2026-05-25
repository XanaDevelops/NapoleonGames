extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetServer.net_start_game.connect(_on_start_game)
	NetServer.net_end_game.connect(_on_end_game)

func _on_start_game(info: GameConfig) -> void:
	var label := Label.new()
	label.text = "Partida {0}: {1} vs {2}".format([info.game_pid, info.user_a.name, info.user_b.name])
	label.set_meta("gid", info.game_pid)
	self.add_child.call_deferred(label)
	
func _on_end_game(game_pid: int) -> void:
	for l: Label in get_children():
		if l.get_meta("gid", game_pid):
			remove_child.call_deferred(l)
			break
