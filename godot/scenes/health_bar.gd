extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar =$DamageBar

var bar_value= 0: set = _set_value


func _set_value(new_value):
	var prev_value = bar_value
	bar_value = min(max_value, new_value)
	value = bar_value
	
	if bar_value <=0:
		queue_free()
	if bar_value < prev_value: 
		timer.start()
	
	else:
		damage_bar.value = bar_value
		
func init(_value):
	max_value = _value
	bar_value= _value
	value = bar_value
	damage_bar.max_value = bar_value
	damage_bar.value = bar_value


func _on_timer_timeout() -> void:
	damage_bar.value = bar_value
	
