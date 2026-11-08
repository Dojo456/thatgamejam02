extends Node2D

@onready var one: Node2D = $One
@onready var two: Node2D = $Two


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat: ShaderMaterial
	
	if randf() > 0.5:
		one.hide()
		two.show()
		mat = $Two/Sprite2D.material
	else:
		one.show()
		two.hide()
		mat = $One/Sprite2D.material

	mat.set_shader_parameter("wind_start", randf_range(-1.57, 1.57))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
