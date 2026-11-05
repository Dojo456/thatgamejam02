@tool

class_name InputTimestamp
extends Resource

enum Inputs {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var timestamp: float:
	set(val):
		timestamp = val
		_set_name()
@export var input: Inputs:
	set(val):
		input = val
		_set_name()
		
func _set_name() -> void:
	resource_name = "%.2f - %s" % [timestamp, Inputs.keys()[input]]
	emit_changed()
