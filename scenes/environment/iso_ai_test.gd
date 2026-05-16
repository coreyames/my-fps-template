extends Node3D

var level_collision_id: int

func _ready() -> void:
	level_collision_id = $Level.get_instance_id()
	return

func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("waypoint"):	
	return	
