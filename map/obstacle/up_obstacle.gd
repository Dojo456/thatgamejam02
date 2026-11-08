extends Node2D

@onready var options = [
	$One,
	$Two,
	$Three
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chosen = randi_range(0, options.size() - 1)
	
	for i in range(options.size()):
		if i != chosen:
			options[i].hide()
			
	options[chosen].show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
