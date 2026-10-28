@tool

extends Node2D

@onready var map = $Map
@onready var char = $Character

var map_initial: Vector2
var char_initial: Vector2

@export var map_speed = 300
@export var time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_initial = map.position
	char_initial = char.position

func reset(): 
	char.position = char_initial
	char.velocity = Vector2.ZERO
	char.current_action = "none"
	time = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():	
		time += delta
	map.position.x = map_initial.x - (map_speed * time)

	if Input.is_action_just_pressed("reset"):
		reset()
