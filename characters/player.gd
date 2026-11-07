@tool

class_name Player
extends Node2D

@onready var base_char: BaseCharacter = $BaseCharacter
@onready var sprite: AnimatedSprite2D = $BaseCharacter/AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("run")
	
func reset():
	base_char.current_action = BaseCharacter.Action.NONE
	base_char.velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		base_char.perform_action(BaseCharacter.Action.UP)
		$BaseCharacter/AnimatedSprite2D.play("jump")
	elif event.is_action_pressed("down"):
		base_char.perform_action(BaseCharacter.Action.DOWN)
		$BaseCharacter/AnimatedSprite2D.play("duck")
	elif event.is_action_pressed("right"):
		base_char.perform_action(BaseCharacter.Action.RIGHT)
		$BaseCharacter/AnimatedSprite2D.play("forward")
	elif event.is_action_pressed("left"):
		base_char.perform_action(BaseCharacter.Action.LEFT)
		$BaseCharacter/AnimatedSprite2D.play("fallback")
	else: $BaseCharacter/AnimatedSprite2D.play("run")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
