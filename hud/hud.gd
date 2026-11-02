@tool

extends Control

@onready var input_bar = $Panel
@onready var input_indicator = $Panel/Button
@onready var input_timestamps = $Panel/Control
@onready var time_label = $TimeLabel

@export var track_info: TrackInfo
@export var speed: int = 64
@export var timing_offset: int = 0
@export var time: float
@export var input_indicator_scene: PackedScene
var input_offset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_input_indicators()
	
	input_offset = input_indicator.position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_rebuild_input_indicators()
		
	input_timestamps.position.x = time * speed * -1
	time_label.text = str(time)

func _rebuild_input_indicators():
	for child in input_timestamps.get_children():
		child.queue_free()
	
	for input in track_info.inputs_list:
		var i: InputIndicator = input_indicator_scene.instantiate()
		i.input = input
		i.position.x = (input.timestamp * speed) + timing_offset + input_offset
		
		input_timestamps.add_child(i)
