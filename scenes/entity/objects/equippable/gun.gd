class_name Gun
extends Node3D

var ammo_scene = preload("res://proj.tscn");
const PROJ_SPAWN_Z_OFFSET = 0.57;
const PROJ_SPAWN_Y_OFFSET = 0.077;
	
func use(direction: Vector3) -> void:
	var projectile: Proj = ammo_scene.instantiate();
	projectile.position = global_position;
	projectile.rotation = global_rotation;
	projectile.translate_object_local(Vector3(0, PROJ_SPAWN_Y_OFFSET, PROJ_SPAWN_Z_OFFSET));
	get_node("/root").add_child(projectile);
	$AnimationPlayer.play("use");
	projectile.fire(direction); 
	return;
