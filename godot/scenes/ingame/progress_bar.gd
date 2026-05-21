class_name LoadGame
extends ProgressBar

@export var progress_bar:ProgressBar
var _tween:Tween = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	progress_bar.value=0
	progress_bar.max_value=100
	_animate()

func _animate() -> void:
	_tween = create_tween()
	# Simular pasos de carga
	_tween.tween_property(progress_bar, "value", 30, 0.4).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_interval(0.1)
	_tween.tween_property(progress_bar, "value", 60, 0.5).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_interval(0.15)
	_tween.tween_property(progress_bar, "value", 85, 0.3).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_interval(0.2)
	_tween.tween_property(progress_bar, "value", 100, 0.4).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_callback(_on_load_complete)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_load_complete()-> void:
	pass
