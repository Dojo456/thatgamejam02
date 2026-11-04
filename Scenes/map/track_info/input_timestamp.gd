class_name InputTimestamp
extends Resource

enum Inputs {
	UP,
	DOWN,
	LEFT,
	RIGHT
} ##possible inputs for player character

@export var timestamp: float
@export var input: Inputs
