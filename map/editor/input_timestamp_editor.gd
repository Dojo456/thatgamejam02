@tool
class_name InputTimestampEditor
extends Node2D

@export var input_timestamp: InputTimestamp

@onready var text_edit: TextEdit = $TextEdit
@onready var options: OptionButton = $OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options.add_item("Up")
	options.add_item("Down")
	options.add_item("Left")
	options.add_item("Right")
	
	options.item_selected.connect(_changed_value)
	text_edit.text_changed.connect(_changed_value)
	
	options.select(reversed[input_timestamp.input])
	text_edit.text = "%.2f" % input_timestamp.timestamp

const indexes = {
	0: InputTimestamp.Inputs.UP,
	1: InputTimestamp.Inputs.DOWN,
	2: InputTimestamp.Inputs.LEFT,
	3: InputTimestamp.Inputs.RIGHT,
}
	
func _changed_value():
	input_timestamp.input = indexes[options.selected]
	input_timestamp.timestamp = float(text_edit.text)
	
const reversed = {
	InputTimestamp.Inputs.UP: 0,
	InputTimestamp.Inputs.DOWN: 1,
	InputTimestamp.Inputs.LEFT: 2,
	InputTimestamp.Inputs.RIGHT: 3,
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if input_timestamp:
		options.select(reversed[input_timestamp.input])
		text_edit.text = "%.2f" % input_timestamp.timestamp
