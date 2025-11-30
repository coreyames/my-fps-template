class_name Gun
extends Node3D

var ammo_scene = preload("res://proj.tscn");
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func use(direction: Vector3) -> void:
	var projectile: Proj = ammo_scene.instantiate();
	add_child(projectile);
	$AnimationPlayer.play("use");
	projectile.fire(direction); 
