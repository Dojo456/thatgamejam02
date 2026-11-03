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

# Characters
@onready var lead_char: LeadCharacter = $LeadCharacter
@onready var player: Player = $Player

# Control / special nodes
@onready var hud = $Hud
@onready var audio_player = $AudioStreamPlayer

var map_initial: Vector2
var player_initial: Vector2
var lead_initial: Vector2

@export var map_speed = 300
@export var time: float = 0
@export var start_time: float = 2
@export var timing_offset: int = 96
## 'track_info' holds the resouce that contains the MP3 file to be played and a list of InputTimestamps
## Each InputTimestamp contains a 'time' and an 'input' of either UP, DOWN, LEFT, RIGHT
@export var track_info: TrackInfo

## The index of the next timestamp the user will encounter. This is the timestamp to compare current inputs against
var next_timestamp_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_initial = map.position
	player_initial = player.position
	lead_initial = lead_char.position
	
	map_viewer.speed = map_speed
	hud.speed = map_speed
	map_viewer.track_info = track_info
	hud.track_info = track_info
	lead_char.track_info = track_info
	
	audio_player.stream = track_info.file
	next_timestamp_index = 0
	
	reset()

## Reset initializes variables to an acceptable start state and can be done repeatedly
func reset():
	# Reset children
	player.position = player_initial
	player.reset()
	lead_char.reset()
	
	# Stop and queue audio playback
	audio_player.stop()
	get_tree().create_timer(start_time).timeout.connect(audio_player.play)
	
	# Reset timing variables
	time = -start_time
	next_timestamp_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		time += delta
		
		var ts = track_info.inputs_list.get(next_timestamp_index)
		
		if ts and time > ts.timestamp:
			next_timestamp_index += 1
		
		if Input.is_action_just_pressed("reset"):
			reset()
			
	# Propagate down time, and then move the map based on time
	# The HUD moves the input timestamp list internally. Potentially a refactor is 
	# to move map position logic to be internal within MapHolder as well
	hud.time = time
	lead_char.time = time + ((lead_initial.x - player_initial.x) / map_speed)
	map.position.x = player_initial.x + timing_offset - (map_speed * time)
	
	# Set any audio effects, for now there are none
	var bus_idx = AudioServer.get_bus_index("Master")
	var pitch_effect: AudioEffectPitchShift = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectPitchShift
	pitch_effect.pitch_scale = 1

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
