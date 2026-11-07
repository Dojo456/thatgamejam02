extends Node

@onready var ui: Control = $UI
@onready var game: Control = $Game
@onready var game_viewport: SubViewport = $Game/SubViewport

@export var game_scene: PackedScene = preload("res://Scenes/root.tscn")

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("pause"):
		paused = !paused
		if paused:
			_unpause_game()
		else:
			_pause_game()
	
func _start_game():
	ui.hide()
	for child in game_viewport.get_children():
		child.queue_free()
	game_viewport.add_child(game_scene.instantiate())
	game.show()
	_unpause_game()
	
func _pause_game():
	ui.show()
	game.hide()
	get_tree().paused = true
	
func _unpause_game():
	ui.hide()
	game.show()
	get_tree().paused = false


func _on_start_button_pressed() -> void:
	_start_game()
