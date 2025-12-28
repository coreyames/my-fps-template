class_name Gun
extends Node3D

var ammo_scene = preload("res://proj.tscn");
const PROJ_SPAWN_Z_OFFSET = -0.623;
const PROJ_SPAWN_Y_OFFSET = 0.076;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func use(direction: Vector3) -> void:
	var projectile: Proj = ammo_scene.instantiate();
	projectile.position.z = global_position.z + PROJ_SPAWN_Z_OFFSET;
	#projectile.position.z = global_position.z + ;
	projectile.position.y = global_position.y + PROJ_SPAWN_Y_OFFSET;
	projectile.position.x = global_position.x;
	#projectile.global_position.z = global_position.z;
	#projectile.global_position.y = global_position.y;
	get_node("/root").add_child(projectile);
	$AnimationPlayer.play("use");
	projectile.fire(direction); 
