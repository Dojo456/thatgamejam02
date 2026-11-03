extends Node2D

@onready var purple = $Purple
@onready var default = $Default


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() < 0.5:
		purple.hide()
	else:
		default.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
