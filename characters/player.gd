class_name Player
extends Node2D

@onready var char: BaseCharacter = $BaseCharacter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func reset():
	char.current_action = BaseCharacter.Action.NONE
	char.velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		char.perform_action(BaseCharacter.Action.UP)
	elif event.is_action_pressed("down"):
		char.perform_action(BaseCharacter.Action.DOWN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
