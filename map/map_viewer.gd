@tool
class_name MapViewer
extends Node2D

@onready var holder: Node2D = $Holder
@onready var obstacles = $Holder/Obstacles
@onready var statics: Node2D = $Holder/Statics
@onready var background: Sprite2D = $Holder/Statics/Background
@onready var top_bush: Sprite2D = $Holder/Statics/TopBush
@onready var bottom_bush: Sprite2D = $Holder/Statics/BottomBush
@onready var top_tree_holder: Node2D = $Holder/Statics/TopTreeHolder
@onready var bottom_tree_holder: Node2D = $Holder/Statics/BottomTreeHolder
@onready var top_tree_region: ReferenceRect = $Holder/Statics/TopTreeRegion
@onready var bottom_tree_region: ReferenceRect = $Holder/Statics/BottomTreeRegion

@export var show_static: bool = false:
	set(val):
		show_static = val
		
		if statics:
			statics.visible = val

## Speed in pixels per second
@export var speed: int = 64
@export var time: float = 0.0 
@export var timing_offset: int = 0


## The selected TrackInfo resource to be viewed
@export var track_info: TrackInfo
@export var obstacle_bindings: Dictionary[InputTimestamp.Inputs, PackedScene]

# Elements to control decoration
@export var tree_density: float = 1.0
@export_tool_button("Rebuild trees") var _rebuild_trees = _rebuild_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rebuild_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_rebuild_map(false)
		
	holder.position.x = (speed * -time) + timing_offset

var tree_scene: PackedScene = preload("res://map/decorations/tree.tscn")

func _rebuild_map(build_trees = true):
	# Return if no input lists for null errors
	if not track_info or not track_info.file or track_info.inputs_list.size() < 1:
		return
		
	# Clear all obstacles and then add new ones
	for children in obstacles.get_children():
		children.queue_free()
	
	for input in track_info.inputs_list:
		var scene = obstacle_bindings[input.input]
		
		assert(scene != null, "No scene for bindings %s" % input.input)
		
		var n: Node2D = scene.instantiate()
		n.position.x = input.timestamp * speed
		obstacles.add_child(n)
		
	var map_width = track_info.file.get_length() * speed
	
	# Generate map background
	background.region_rect = Rect2(Vector2.ZERO, Vector2(map_width, 360))
	
	# Generate boundary bushes
	top_bush.region_rect = Rect2(Vector2.ZERO, Vector2(map_width, 32))
	bottom_bush.region_rect = Rect2(Vector2.ZERO, Vector2(map_width, 32))
	
	# Place trees
	top_tree_region.size.x = map_width
	bottom_tree_region.size.x = map_width
	
	if build_trees:
		for child in top_tree_holder.get_children():
			child.queue_free()
			
		for child in bottom_tree_holder.get_children():
			child.queue_free()
		
		top_tree_holder.position = top_tree_region.position
		bottom_tree_holder.position = bottom_tree_region.position
		
		var tree_count = map_width / 64 * tree_density
		
		
		for i in range(tree_count):
			var top_tree: Node2D = tree_scene.instantiate()
			top_tree.position = Vector2(
				randi_range(0, top_tree_region.size.x),
				randi_range(0, top_tree_region.size.y),
			)
			
			top_tree_holder.add_child(top_tree)
			
			var bottom_tree: Node2D = tree_scene.instantiate()
			bottom_tree.position = Vector2(
				randi_range(0, top_tree_region.size.x),
				randi_range(0, top_tree_region.size.y),
			)
			
			bottom_tree_holder.add_child(bottom_tree)
		
		
