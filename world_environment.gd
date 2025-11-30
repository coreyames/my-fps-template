# thanks to https://kelvinvanhoorn.com/2024/12/07/skybox-tutorial-godot
@tool
extends WorldEnvironment

@export var sun: DirectionalLight3D
@export var moon: Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var sun_dir = sun.get_global_transform().basis.z; # This is our forward direction pointing towards the sun
	var moon_dir = moon.get_global_transform().basis.z; # This is our forward direction pointing towards the moon
	environment.sky.sky_material.set_shader_parameter('sun_dir', sun_dir); # Update sky material with sun direction
	environment.sky.sky_material.set_shader_parameter('moon_dir', moon_dir); # Update sky material with moon direction
