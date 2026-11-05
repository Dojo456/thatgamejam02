@tool
class_name ScoreAddIndicator
extends Control

@onready var label: Label = $Label

## diff is the amount the score has been changed by
@export var diff: int = 0

@export_tool_button("Reset") var _reset_button = _reset

var tween: Tween
var j_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset()

func _reset():
	label.text = "%s%d" % ["+" if diff > 0 else "-", diff]
	label.add_theme_font_size_override("font_size", max(16, diff * 1.5))
	
	position.y = 0
	visible = true
	
	if tween:
		tween.kill()
		
	if j_tween:
		j_tween.kill()
	
	# Use tween to animate going up
	tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", -60, 1)
	if Engine.is_editor_hint():
		tween.tween_property(self, "visible", false, 0)
	else:
		tween.tween_callback(self.queue_free)
	
	# Use tween to animate going horizontal jiggle
	j_tween = create_tween().set_loops()
	j_tween.tween_property(self, "position:x", 3, 0.15)
	j_tween.tween_property(self, "position:x", -3, 0.15)
