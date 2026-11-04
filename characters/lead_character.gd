class_name LeadCharacter
extends Node2D

@export var track_info: TrackInfo
@export var time: float = 0.0

var next_timestamp_index: int = 0

@onready var base_char: BaseCharacter = $BaseCharacter
@onready var sprite: AnimatedSprite2D = $BaseCharacter/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	
func reset():
	time = 0.0
	next_timestamp_index = 0

var bindings: Dictionary[InputTimestamp.Inputs, BaseCharacter.Action] = {
	InputTimestamp.Inputs.UP: BaseCharacter.Action.UP,
	InputTimestamp.Inputs.DOWN: BaseCharacter.Action.DOWN,
	InputTimestamp.Inputs.LEFT: BaseCharacter.Action.LEFT,
	InputTimestamp.Inputs.RIGHT: BaseCharacter.Action.RIGHT,
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not track_info or track_info.inputs_list.size() <= 0:
		return
		
	if next_timestamp_index < track_info.inputs_list.size():
		var ts = track_info.inputs_list[next_timestamp_index]
		
		if not ts:
			return
		
		# Now within action timing, perform action and advance to next one
		if ts.timestamp < time + base_char.jump_time:
			base_char.perform_action(bindings[ts.input])
			next_timestamp_index += 1
	
