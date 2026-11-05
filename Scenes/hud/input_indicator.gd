@tool
class_name InputIndicator
extends Control

@export var input: InputTimestamp

@onready var label: Label = $Label
@onready var time_label: Label = $TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _rebuild_display():	
	var binds = {
		InputTimestamp.Inputs.UP: "W",
		InputTimestamp.Inputs.DOWN: "S",
		InputTimestamp.Inputs.LEFT: "A",
		InputTimestamp.Inputs.RIGHT: "D",
	}
	
	label.text = binds[input.input]
	time_label.text = str(input.timestamp)
