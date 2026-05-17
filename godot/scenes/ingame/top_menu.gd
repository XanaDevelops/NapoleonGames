extends PanelContainer


@export var TimeLabel:Label 
@export var TurnLabel: Label
@export var OptionsButton:Button

@export var PhaseLabel:Label

var _elapsed_time:float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_elapsed_time+=delta
	var minuts= int(_elapsed_time)/60
	var seconds= int(_elapsed_time)%60
	TimeLabel.text= "%02d:%02d" %[minuts, seconds]
	pass
