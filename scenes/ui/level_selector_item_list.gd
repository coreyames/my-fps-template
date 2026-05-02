extends ItemList

func _ready() -> void:
	connect("item_selected", _on_item_selected)
	return

func _on_item_selected(index: int):
	if index == 0:
		get_tree().change_scene_to_file("res://scenes/environment/world.tscn")
	elif index == 1:
		get_tree().change_scene_to_file("res://scenes/environment/new_level.tscn")
	return
