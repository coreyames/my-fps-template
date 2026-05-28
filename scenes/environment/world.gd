extends Node3D

var level_collision_id: int

func _ready() -> void:
	Debug.toggle()
	level_collision_id = $Level.get_instance_id()
	return
