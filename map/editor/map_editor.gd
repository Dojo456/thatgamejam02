@tool
## The MapEditor is probably the most important scene in the project as it allows
## for the easy editting of [code]TrackInfo[/code] resources. 
## 
## It can also be used as the main rendering engine for any given TrackInfo resource by just removing all the editor only elements.
class_name MapEditor
extends Node2D

## Timeline elements
@onready var editor_elements: Node2D = $EditorElements
@onready var timestamps: Node2D = $EditorElements/Timestamps
@onready var track_timeline: Line2D = $EditorElements/TrackTimeline
@onready var time_indicator: Node2D = $EditorElements/TimeIndicator

## Obstacle editors 
@onready var timestamp_editors: Node2D = $TimestampEditors

## Map viewer to preview the map being editted
@onready var map_viewer: MapViewer = $MapViewer

## Built in player
@onready var player: AudioStreamPlayer = $AudioStreamPlayer

## Position of the timeline for editor
@export var timeline_pos: int = 384

## Speed in pixels per second
@export var speed: int = 300

## Speed multiplier to control playback speed
@export var mult: float = 1.0:
	set(val):
		mult = clamp(val, 0.0, 10.0)

# Playback controls
@export var time: float = 0
@export var paused: bool = true:
	set(val):
		if not val:
			_play_from_time()
			
		paused = val

## TrackInfo to be editted, will auto set to the MapViewer
@export var track_info: TrackInfo

func _toggle_pause():
	player.stream_paused = not player.stream_paused
	
func _play_from_time():
	player.stream = track_info.file
	player.pitch_scale = mult
	
	var bus_idx = AudioServer.get_bus_index("Master")
	var pitch_effect = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectPitchShift

	pitch_effect.pitch_scale = 1.0 / mult
	
	player.play(time)
	
func _play_from_start():
	time = 0
	_play_from_time()

func _manual_reinit_map():
	map_viewer._rebuild_map()


@export_tool_button("Reinit Editor Elements") var _reinit_map = _manual_reinit_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not track_info or not track_info.file or track_info.inputs_list.size() < 1:
		return
	
	if not paused:
		time += delta * mult
		
	player.stream_paused = paused
	
	map_viewer.track_info = track_info
	map_viewer.speed = speed
	
	var track_length = track_info.file.get_length()
		
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
		
	time_indicator.position = Vector2(time * speed, timeline_pos)
	
	for child in timestamp_editors.get_children():
		child.queue_free()
	
	for input_timestamp in track_info.inputs_list:
		var n: InputTimestampEditor = preload("res://map/editor/input_timestamp_editor.tscn").instantiate()
		n.input_timestamp = input_timestamp
		
		n.position.y = -128
		n.position.x = input_timestamp.timestamp * speed
		
		timestamp_editors.add_child(n)
