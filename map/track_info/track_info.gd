@tool
class_name TrackInfo
extends Resource

@export var name: String
@export var file: AudioStreamMP3

@export var inputs_list: Array[InputTimestamp]:
	set(val):
		inputs_list = _replace_nulls(val)
		emit_changed()

func _manual_clean() -> void:
	inputs_list = _replace_nulls(inputs_list)
	notify_property_list_changed()
	
@export_tool_button("Clean Nulls in Array")
var _clean_button = _manual_clean
		
func _replace_nulls(arr: Array[InputTimestamp]) -> Array[InputTimestamp]:
	if arr == null:
		return []
	
	var cleaned: Array[InputTimestamp] = []
	for item in arr:
		if item == null or not item is InputTimestamp:
			cleaned.append(InputTimestamp.new())
		else:
			cleaned.append(item)
			
	var sort_func = func(a: InputTimestamp, b: InputTimestamp):
		return a.timestamp < b.timestamp
			
	cleaned.sort_custom(sort_func)
	
	return cleaned

func _init() -> void:
	for input in inputs_list:
		input.resize(2)
