extends ItemList

func _ready() -> void:
	connect("item_selected", _on_item_selected)
	return

func _on_item_selected(index: int):
	if index == 0:
		get_tree().change_scene_to_file("res://scenes/world_root.tscn")
	return
