@tool

## The root node contains the majority of the game logic, more specifically these components:
## - Handles root time tracker via the 'time' variable
## - Track info loading and audio playing
## - Moves the map based on 'time'
## - Propagates 'time' down to the 'Hud' node, which handles time internally
## - Compares user inputs with the expected 'track_info' inputs

extends Node2D

@onready var map = $MapHolder
@onready var map_viewer: MapViewer = $MapHolder/MapViewer
@onready var char: Character = $Character
@onready var hud = $Hud
@onready var player = $AudioStreamPlayer

var map_initial: Vector2
var char_initial: Vector2

@export var map_speed = 300
@export var time: float = 0
@export var start_time: float = 5
@export var timing_offset: int = 96
## 'track_info' holds the resouce that contains the MP3 file to be played and a list of InputTimestamps
## Each InputTimestamp contains a 'time' and an 'input' of either UP, DOWN, LEFT, RIGHT
@export var track_info: TrackInfo

## The index of the next timestamp the user will encounter. This is the timestamp to compare current inputs against
var next_timestamp_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_initial = map.position
	char_initial = char.position
	
	map_viewer.speed = map_speed
	hud.speed = map_speed
	map_viewer.track_info = track_info
	hud.track_info = track_info
	
	player.stream = track_info.file
	next_timestamp_index = 0
	
	reset()

## Reset initializes variables to an acceptable start state and can be done repeatedly
func reset():
	player.stop()
	char.position = char_initial
	char.velocity = Vector2.ZERO
	char.current_action = "none"
	
	get_tree().create_timer(start_time).timeout.connect(player.play)
	time = -start_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		time += delta
		
		var ts = track_info.inputs_list.get(next_timestamp_index)
		
		if not ts:
			print("input list index out of bounds!")
			return
		
		if time > ts.timestamp:
			next_timestamp_index += 1
		
		if Input.is_action_just_pressed("reset"):
			reset()
			
	# Propagate down time, and then move the map based on time
	# The HUD moves the input timestamp list internally. Potentially a refactor is 
	# to move map position logic to be internal within MapHolder as well
	hud.time = time
	map.position.x = char_initial.x + timing_offset - (map_speed * time)

## 'action_map' maps Godot engine action's that can be set in project settings
## to InputTimestamp enum values
var action_map = {
	"up": InputTimestamp.Inputs.UP,
	"down": InputTimestamp.Inputs.DOWN,
	"left": InputTimestamp.Inputs.LEFT,
	"right": InputTimestamp.Inputs.RIGHT,
}

func _input(event: InputEvent) -> void:
	if event is InputEventAction:
		var input = action_map.get(event.action)
		
		var ts = track_info.inputs_list[next_timestamp_index]
		
		# TODO: implement actual comparison / scoring logic for inputs
		# Also need to figure out a way to propagate down to HUD and display it
		if input:
			if input == ts.input:
				print("good")
			else:
				print("bad")
