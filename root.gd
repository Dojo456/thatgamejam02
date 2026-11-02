@tool

extends Node2D

@onready var map = $MapHolder
@onready var map_editor: MapEditor = $MapHolder/MapEditor
@onready var char = $Character
@onready var hud = $Hud
@onready var player = $AudioStreamPlayer

var map_initial: Vector2
var char_initial: Vector2

@export var map_speed = 300
@export var time: float = 0
@export var start_time: float = 5
@export var timing_offset: int = 96
@export var track_info: TrackInfo

var next_timestamp_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_initial = map.position
	char_initial = char.position
	
	map_editor.speed = map_speed
	hud.speed = map_speed
	map_editor.track_info = track_info
	hud.track_info = track_info
	
	player.stream = track_info.file
	next_timestamp_index = 0
	
	reset()

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
		
		var ts = track_info.inputs_list[next_timestamp_index]
		
		if time > ts.timestamp:
			next_timestamp_index += 1
		
		if Input.is_action_just_pressed("reset"):
			reset()
			
	hud.time = time
	map.position.x = char_initial.x + timing_offset - (map_speed * time)

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
		
		if input:
			if input == ts.input:
				print("good")
			else:
				print("bad")
