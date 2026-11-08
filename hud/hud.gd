@tool
class_name Hud
extends Control

@export var debug: bool = true

@onready var input_bar = $Panel
@onready var input_indicator = $Panel/Button
@onready var input_timestamps = $Panel/Control

# Debug
@onready var debug_hud: Control = $Debug
@onready var time_label: Label = $Debug/TimeLabel
@onready var fps_counter: Label = $Debug/FPSCounter

@export var track_info: TrackInfo
@export var speed: int = 64
@export var timing_offset: int = 0
@export var time: float
@export var input_indicator_scene: PackedScene

var input_offset: int = 0

# Input indicator controls
@export var input_indicator_color: Color = Color.DARK_GRAY:
	set(val):
		if input_indicator:
			var sb = StyleBoxFlat.new()
			sb.set_corner_radius_all(24)
			sb.bg_color = val
			
			input_indicator.add_theme_stylebox_override("normal", sb)
			
			input_indicator_color = val

# Scoring controls
@onready var score_label: Label = $HBoxContainer/PanelContainer/ScoreLabel
@onready var score_add_spawnpoint: Marker2D = $ScoreAddSpawnpoint
var score_add_indicator = preload("res://hud/add_score_indicator.tscn")
@export var score: int = 0:
	set(val):
		var diff = val - score
		
		if diff:
			var n = score_add_indicator.instantiate() as ScoreAddIndicator
			n.diff = diff
			
			score_add_spawnpoint.add_child(n)
		
		score = val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_input_indicators()
	
	input_offset = input_indicator.position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_rebuild_input_indicators()
		
	debug_hud.visible = debug
		
	fps_counter.text = "%.2f fps" % Engine.get_frames_per_second()
		
	input_timestamps.position.x = time * speed * -1
	time_label.text = str(time)
	score_label.text = str(score)

func _rebuild_input_indicators():
	for child in input_timestamps.get_children():
		child.queue_free()
	
	for input in track_info.inputs_list:
		var i: InputIndicator = input_indicator_scene.instantiate()
		i.debug = debug
		i.input = input
		i.position.x = (input.timestamp * speed) + timing_offset + input_offset
		
		input_timestamps.add_child(i)
