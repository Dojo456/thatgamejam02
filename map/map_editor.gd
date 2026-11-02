@tool
class_name MapEditor
extends Node2D

@onready var obstacles = $Obstacles
@onready var editor_elements: Node2D = $EditorElements
@onready var timestamps: Node2D = $EditorElements/Timestamps
@onready var track_timeline: Line2D = $EditorElements/TrackTimeline

## Speed in pixels per second
@export var speed: int = 64

## Position of the timeline for editor
@export var timeline_pos: int = 384

@export var track_info: TrackInfo
@export var obstacle_bindings: Dictionary[InputTimestamp.Inputs, PackedScene]

func _manual_reinit_map():
	_rebuild_map()

@export_tool_button("Reinit Editor Elements") var _reinit_map = _manual_reinit_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_map()	
	
	if not Engine.is_editor_hint():
		editor_elements.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_rebuild_map(true)

func _rebuild_map(obstacles_only = false):
	if not obstacles_only:
		var player = AudioStreamPlayer.new()
		
		player.stream = track_info.file
		
		var track_length = player.stream.get_length()
		
		player.queue_free()
		
		track_timeline.points = [Vector2(0, timeline_pos), Vector2(speed * track_length, timeline_pos)]
		
		var timestamp_step = 5
		
		for child in timestamps.get_children():
			child.queue_free()
		
		for i in range(ceil(track_length / timestamp_step)):
			var label = Label.new()
			label.text = "%ss" % (i * timestamp_step)
			label.set_position(Vector2(i * timestamp_step * speed, timeline_pos + 32))
			
			label.add_theme_font_size_override("font_size", 32)
			
			timestamps.add_child(label)
	
	for children in obstacles.get_children():
		children.queue_free()
	
	for input in track_info.inputs_list:
		var n: Node2D = obstacle_bindings[input.input].instantiate()
		n.position.x = input.timestamp * speed
		obstacles.add_child(n)
