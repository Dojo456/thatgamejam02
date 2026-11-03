class_name BaseCharacter
extends CharacterBody2D

@onready var timer: Timer = $Timer

enum Action {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE,
	RESET
}

var current_action: Action = Action.NONE

## 'initial_pos' is the default position the character will reset to
var initial_pos: Vector2
## Controls how tall the jump is in terms of pixels
@export var jump_height = Vector2(0, 128)

## How long it takes to move from default position to peak of jump position
@export var jump_time = 0.2
## How long you will remain in the jump position before auto-reset
@export var hang_time = 0.1
## How long auto-reset takes to return from peak of jump to default
@export var reset_time = 0.1

## If true, character will return to default position after input
@export var auto_resets = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = global_position

## Resets the character to default position after a 'time' delay
func reset_in(time: float):
	if auto_resets:
		timer.start(time + hang_time)
		var on_timeout = func():
			current_action = Action.RESET
			velocity = global_position - initial_pos / reset_time
		timer.timeout.connect(on_timeout)
	else: 
		initial_pos = global_position
		
func perform_action(action: Action):
	match action:
		Action.UP:
			current_action = Action.UP
			velocity.y = -jump_height.y / jump_time
			reset_in(jump_time)
		Action.DOWN:
			current_action = Action.DOWN
			velocity.y = jump_height.y / jump_time
			reset_in(jump_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:		
	match current_action:
		Action.NONE:
			velocity = Vector2.ZERO
		Action.UP:
			global_position = global_position.move_toward(initial_pos - jump_height, abs(velocity.y * delta))
		Action.DOWN:
			global_position = global_position.move_toward(initial_pos + jump_height, abs(velocity.y * delta))
		Action.RESET:
			global_position = global_position.move_toward(initial_pos, velocity.length() * delta)
			
			if global_position.is_equal_approx(initial_pos): # reached ground
				global_position = initial_pos
				current_action = Action.NONE
	
