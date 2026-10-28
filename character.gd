extends CharacterBody2D

@onready var timer: Timer = $Timer

var current_action = "none"

var initial_pos: Vector2
@export var jump_height = Vector2(0, 128)

@export var jump_time = 0.2
@export var hang_time = 0.1
@export var reset_time = 0.1

@export var auto_resets = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = global_position
	
func reset_in(time: float):
	if not auto_resets:
		initial_pos = global_position
	
	if auto_resets:
		timer.start(time + hang_time)
		var on_timeout = func():
			current_action = "reset"
			velocity = global_position - initial_pos / reset_time
		timer.timeout.connect(on_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		current_action = "jump_up"
		velocity.y = -jump_height.y / jump_time
		reset_in(jump_time)
	elif Input.is_action_just_pressed("down"):
		current_action = "duck_down"
		velocity.y = jump_height.y / jump_time
		reset_in(jump_time)
		
	match current_action:
		"none":
			velocity = Vector2.ZERO
		"jump_up":
			position = position.move_toward(initial_pos - jump_height, abs(velocity.y * delta))
		"duck_down":
			position = position.move_toward(initial_pos + jump_height, abs(velocity.y * delta))
		"reset":
			position = position.move_toward(initial_pos, velocity.length() * delta)
			
			if position.is_equal_approx(initial_pos): # reached ground
				position = initial_pos
				current_action = "none"
	
