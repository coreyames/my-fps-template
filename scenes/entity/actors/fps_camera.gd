# thanks to https://yosoyfreeman.github.io/article/godot/tutorial
#	/achieving-better-mouse-input-in-godot-4-the-perfect-camera-controller

extends Camera3D

var body: CharacterBody3D
var motion: Vector2

var sens: float = Settings.mouse_sensitivity_value

# probably not changing?
const ABS_PITCH_MAX: float = 89

func _ready() -> void:
	add_to_group("settings_dependent")
	body = get_parent()
	Input.set_use_accumulated_input(false)

func _unhandled_input(event) -> void:
	if $"..".is_console_open:
		return
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			look(event)
		else:
			motion = Vector2.ZERO
	return
	
# Rotates the character around the local Y axis
func yaw(amount) -> void:
	if is_zero_approx(amount):
		return
	body.rotate_object_local(Vector3.DOWN, deg_to_rad(amount))
	body.orthonormalize()
	return

# Rotates the cam around the local x axis 
func pitch_with_clamp(amount) -> void:
	if is_zero_approx(amount):
		return
	rotate_object_local(Vector3.LEFT, deg_to_rad(amount))
	if abs(rotation.x) > deg_to_rad(ABS_PITCH_MAX):
		rotation.x = clamp(rotation.x, deg_to_rad(-ABS_PITCH_MAX), deg_to_rad(ABS_PITCH_MAX))
	orthonormalize()
	return

func look(event: InputEventMouseMotion) -> void:
	motion = event.relative
	motion *= 0.0005*sens
	yaw(motion.x)
	pitch_with_clamp(motion.y)
	return
	
func refresh_settings() -> void:
	sens = Settings.mouse_sensitivity_value
	return
