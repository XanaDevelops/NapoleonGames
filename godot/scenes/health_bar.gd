
extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var bar_value: int = 0
func init(max_val: int) -> void:
	max_value = max_val
	value = max_val
	damage_bar.max_value = max_val
	damage_bar.value = max_val

func update(new_value: int) -> void:
	var prev = bar_value
	bar_value = new_value
	value = bar_value
	if bar_value < prev:
		timer.start()
	else:
		damage_bar.value = bar_value

func set_value_silent(new_value: int) -> void:
	bar_value = new_value
	value = new_value
	damage_bar.value = new_value

func _on_timer_timeout() -> void:
	damage_bar.value = bar_value
