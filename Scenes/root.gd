@tool

## The root node contains the majority of the game logic, more specifically these components:
##
## - Handles root time tracker via the 'time' variable [br]
## - Track info loading and audio playing [br]
## - Moves the map based on 'time' [br]
## - Propagates 'time' down to the 'Hud' node, which handles time internally [br]
## - Compares user inputs with the expected 'track_info' inputs [br]
class_name Root
extends Node2D

@export var debug = true

@onready var map = $MapHolder
@onready var map_viewer: MapViewer = $MapHolder/MapViewer

# Characters
@onready var lead_char: LeadCharacter = $LeadCharacter
@onready var player: Player = $Player

# Control / special nodes
@onready var hud: Hud = $Hud
@onready var audio_player = $AudioStreamPlayer

var map_initial: Vector2
var player_initial: Vector2
var lead_initial: Vector2

@export var map_speed = 300
@export var time: float = 0
@export var start_time: float = 2

# Some offset variables to have more precise manual control of timing
## timing_offset controls the number of pixels the map is offset
@export var timing_offset: int = 48
@export var input_timing_offset: int = 48
## lead_character_offset controls the number of pixels the lead character is offset.
## It also is calculated into time by dividing by map_speed
@export var lead_character_offset: int = 32

## 'track_info' holds the resouce that contains the MP3 file to be played and a list of InputTimestamps
## Each InputTimestamp contains a 'time' and an 'input' of either UP, DOWN, LEFT, RIGHT
@export var track_info: TrackInfo

# Scoring controls
@export var score: int = 0
@export var combo: int = 0

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
	
	if not Engine.is_editor_hint():
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
	
	score = 0
	
var hud_color_timings: Dictionary[float, Color] = {
	-0.3: Color.RED,
	-0.2: Color.YELLOW,
	-0.1: Color.GREEN,
	0.05: Color.GREEN,
	0.1: Color.RED,
	0.15: Color.DARK_GRAY,
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hud.debug = debug
	
	var ts: InputTimestamp
	# Technically we dont need this if statement is better designed, but easier this way to add a redundant check
	if next_timestamp_index < track_info.inputs_list.size():
		ts = track_info.inputs_list[next_timestamp_index]
		
		# The last element of the hud_timing dictionary is the latest you can perform an input
		# AFTER the input has passed for it to be still counted as that input as opposed to the next
		var latest_timing = hud_color_timings.keys()[hud_color_timings.size() - 1]
			
		if ts and time > ts.timestamp + latest_timing:
			next_timestamp_index += 1
			
	# Propagate down time, and then move the map based on time
	# The HUD moves the input timestamp list internally. Potentially a refactor is 
	# to move map position logic to be internal within MapHolder as well
	hud.time = time
	hud.timing_offset = input_timing_offset
	
	map_viewer.time = time
	map_viewer.timing_offset = timing_offset
	
	lead_char.time = time + ((lead_initial.x  + lead_character_offset - player_initial.x) / map_speed)
	
	# Propagate down speed and other values
	map_viewer.speed = map_speed
	hud.speed = map_speed
	hud.score = score
	
	# Set Hud input indicator based on timing
	var within_timing = false
	
	var hud_input_indicator_color = Color.DARK_GRAY
	
	if ts:
		var timing_diff = time - ts.timestamp
				
		# Godot dictionary order is preserved
		for timing in hud_color_timings.keys():
			if timing_diff > timing:
				hud_input_indicator_color = hud_color_timings[timing]
				
	hud.input_indicator_color = hud_input_indicator_color
	
	# Set any audio effects, for now there are none
	var bus_idx = AudioServer.get_bus_index("Master")
	var pitch_effect: AudioEffectPitchShift = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectPitchShift
	pitch_effect.pitch_scale = 1
	
	if not Engine.is_editor_hint():
		time += delta
		
		if Input.is_action_just_pressed("reset"):
			reset()

## 'action_map' maps Godot engine action's that can be set in project settings
## to InputTimestamp enum values
var action_map = {
	"up": InputTimestamp.Inputs.UP,
	"down": InputTimestamp.Inputs.DOWN,
	"left": InputTimestamp.Inputs.LEFT,
	"right": InputTimestamp.Inputs.RIGHT,
}

var score_timings = {
	-0.3: 5,
	-0.2: 10,
	-0.1: 20,
	0.05: 20,
	0.1: 5,
	0.15: 0
}

func _input(event: InputEvent) -> void:
	for action in action_map:
		if event.is_action_pressed(action):
			var input = action_map[action]
			
			
			if next_timestamp_index >= track_info.inputs_list.size():
				return
			
			var ts = track_info.inputs_list[next_timestamp_index]
			
			if ts.input == input:
				var timing_diff = time - ts.timestamp
				
				var success = false
				var score_add = 0
				var combo_add = -combo
				
				var hit = false
				
				# Godot dictionary order is preserved
				for timing in score_timings.keys():
					if timing_diff > timing:
						score_add = score_timings[timing]
						combo_add = 1
						hit = true
						
				score += score_add
				combo += combo_add
				if hit:
					next_timestamp_index += 1
