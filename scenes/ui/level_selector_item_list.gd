extends  Node

func _ready() -> void:
	$ItemList.item_selected.connect(_on_item_selected)
	return

var done: bool = false
func _on_item_selected(index: int) -> void:
	if !is_inside_tree() || done:
		return
	done = true
	if index == 0:
		get_tree().change_scene_to_file.bind("res://scenes/environment/world.tscn").call_deferred()
	elif index == 1:
		get_tree().change_scene_to_file.bind("res://scenes/environment/new_level.tscn").call_deferred()
	elif index == 2:
		get_tree().change_scene_to_file.bind("res://scenes/environment/world_just_pc.tscn").call_deferred()
	return
