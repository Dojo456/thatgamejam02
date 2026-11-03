@tool
class_name MapViewer
extends Node2D

@onready var obstacles = $Obstacles

## Speed in pixels per second
@export var speed: int = 64

## The selected TrackInfo resource to be viewed
@export var track_info: TrackInfo
@export var obstacle_bindings: Dictionary[InputTimestamp.Inputs, PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_rebuild_map()
		
func _rebuild_map():
	if not track_info or not track_info.file or track_info.inputs_list.size() < 1:
		return
		
	for children in obstacles.get_children():
		children.queue_free()
	
	for input in track_info.inputs_list:
		var n: Node2D = obstacle_bindings[input.input].instantiate()
		n.position.x = input.timestamp * speed
		obstacles.add_child(n)
	
