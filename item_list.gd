extends ItemList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# logs index of first select item
	pass


func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	print(index);
	pass # Replace with function body.


func _on_item_selected(index: int) -> void:
	print("selected");
	pass # Replace with function body.
