extends Marker3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('waypoint'):
		var pc: CharacterBody3D = get_parent().get_node('Player')
		pc.position = position
		pc.velocity = Vector3(0, 0, 0)
