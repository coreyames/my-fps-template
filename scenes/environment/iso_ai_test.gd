extends Node3D

var level_collision_id: int

func _ready() -> void:
	level_collision_id = $Level.get_instance_id()
	$Level.connect("input_event", _on_level_click)
	return

func _on_level_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton && Input.is_action_just_pressed("use"):
		print(event_position)
		$Mob.player_location = event_position
	return 
