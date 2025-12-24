# thanks to https://yosoyfreeman.github.io/article/godot/tutorial
#	/achieving-better-mouse-input-in-godot-4-the-perfect-camera-controller

extends Camera3D

@export_group("nodes")
@export var body: CharacterBody3D
@export var cam: Camera3D

@export_group("settings")
@export_range(1, 100, 1) var sens: float = Settings.mouse_sensitivity

# probably not changing
const ABS_PITCH_MAX: float = 89;

func _ready() -> void:
	Input.set_use_accumulated_input(false)

func _unhandled_input(event)-> void:
	if $"..".is_console_open:
		return;
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			look(event)
			
#Rotates the character around the local Y axis
func yaw(amount)->void:
	if is_zero_approx(amount):
		return
	body.rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	body.orthonormalize();

#Rotates the cam around the local x axis 
func pitch_with_clamp(amount)->void:
	if is_zero_approx(amount):
		return
	cam.rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	if abs(cam.rotation.x) > deg_to_rad(ABS_PITCH_MAX):
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-ABS_PITCH_MAX), deg_to_rad(ABS_PITCH_MAX))
	cam.orthonormalize()

func look(event: InputEventMouseMotion) -> void:
	var motion: Vector2 = event.relative
	motion *= 0.0005*sens
	yaw(motion.x)
	pitch_with_clamp(motion.y)
	
func update_
	 
