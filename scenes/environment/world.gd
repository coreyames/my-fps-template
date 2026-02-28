extends Node3D

var level_collision_id: int

func _ready() -> void:
	$Enemy.stand_still = true
	$NPC.pacifist = true
	$NPC.maintain_pc_los = false
	level_collision_id = $Level.get_instance_id()
	return
