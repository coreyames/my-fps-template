extends CharacterBody3D

signal was_hit

var world_ref: Node3D
var viewport_size_x: float
var viewport_size_y: float
var screen_center: Vector2

#
# PLAYER INFORMATION
#
const NAME_DEFAULT = "PLAYER"
var player_name: String = NAME_DEFAULT

#
# SETTINGS
#
var player_speed_value: float = Settings.player_speed_value
var jump_velocity_value: float = Settings.jump_velocity_value
var air_decel_value: float = Settings.air_decel_value
var air_strafe_accel_value: float = Settings.air_strafe_accel_value
var player_gravity_mult_value: float = Settings.player_gravity_mult_value
var player_max_speed_value: float = Settings.player_max_speed_value
var player_ground_friction_value: float = Settings.player_ground_friction_value
var player_decel_on_input_value:  float = Settings.player_decel_on_input_value
var bhop_frames_value: int = Settings.bhop_frames_value

#
# AUDIO
#
var is_scene_start_jump_sound: bool = true
var is_directed_on_floor: bool = false
var was_airborne: bool = false

const walking_clip: AudioStreamMP3 = preload("res://audio/walking.mp3")
const jump_clip: AudioStreamMP3 = preload("res://audio/jump.mp3")

#
# UI
#
const hud_scene: Resource = preload("res://scenes/ui/hud.tscn")

const console_scene: Resource = preload("res://scenes/ui/dev_console.tscn")
var console_node: Control = null
var is_console_open: bool = false

const menu_scene: Resource = preload("res://scenes/ui/menu.tscn")
var menu_node: Control = null
var in_menu: bool = true
var just_exited_menu: bool = true
var debug_node: Control = null

const char_info_scene: Resource = preload('res://scenes/ui/char_info.tscn')
var char_info_node: Control = null
var is_char_info_open: bool = false

const inventory_scene: Resource = preload('res://scenes/ui/inventory.tscn')
var inventory_node: Control = null
var is_inventory_open: bool = false

#
# EQUIPMENT AND ITEMS
#
const gun_ar_scene: Resource = preload('res://scenes/entity/objects/equippable/gun_ar.tscn')
const gun_ar2_scene: Resource = preload('res://scenes/entity/objects/equippable/gun_ar2.tscn')
var equip1_scene: Resource = gun_ar_scene
var equip2_scene: Resource = gun_ar2_scene

var equipped: Equippable 
var stored: Equippable
var viewmodel: Transform3D

var equipment: Dictionary[String, Equippable] = {
	"w1": null,
	"w2": null,
	"helm": null,
	"chest": null,
	"pack": null
}

#
# STATS
#
var base_stats: Dictionary[String, int] = {
	"HP": 100, # max health
	"SP": 20,  # max skill pts, tmp 'resource'
	"PR": 50,  # phys reduction
	"MR": 50,  # and magic reduction for tmp defense stats
	"SC": 2    # skill cap, determines skill slot count
}

var max_health: int = base_stats.get("HP")
var max_resource: int = base_stats.get("SP")
var cur_health: int = max_health
var cur_resource: int = max_resource
var phys_reduction: int = base_stats.get("PR")
var magic_reduction: int = base_stats.get("MR")
var skill_cap: int = base_stats.get("SC")

#
# ABILITIES
#
var skills: Dictionary[int, Skill] = {}

#
# STATUS, METRICS, OTHER FLAGS
#
var current_speed: float = 0
var recent_top_speed: float = 0
var velocity_when_top: Vector3

var in_strafe: bool = false
var strafe_delta: float = 0
var in_surf: bool = false
var surf_delta: float = 0

var just_landed: bool = false
var bhop_frame_buffer: Array[bool]

func _ready() -> void: 
	world_ref = get_parent()
	viewport_size_x = get_viewport().get_visible_rect().size.x
	viewport_size_y = get_viewport().get_visible_rect().size.y
	screen_center = Vector2(viewport_size_x/2, viewport_size_y/2)

	add_to_group("settings_dependent")
	Debug.connect("toggle_debug", _on_toggle_debug)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Sound.volume_db = -15
	floor_stop_on_slope = false

	if (equip2_scene != null):
		stored = equip2_scene.instantiate()
	equipped = $Camera3D/Equipped
	viewmodel = equipped.transform
	stored.transform = viewmodel
	equipment.set("w1", equipped)
	equipment.set("w2", stored)
	add_stats_from_equipment()
	for i in range(0, skill_cap):
		skills.set(i, null)

	add_child(hud_scene.instantiate())

	bhop_frame_buffer.resize(bhop_frames_value)
	bhop_frame_buffer.fill(false)
	return

func _physics_process(delta: float) -> void:
	# for checking for strafe accel
	var camera_motion: Vector2 = $Camera3D.motion
	
	# gravity, landing sound flags
	if not is_on_floor():
		velocity += (get_gravity() * player_gravity_mult_value) * delta
		if !was_airborne:
			was_airborne = true
	elif was_airborne:
		was_airborne = false
		just_landed = true
		in_strafe = false
		if (strafe_delta > 0):
			Debug.log("strafe end total speed gain:")
			Debug.log("       " + str(strafe_delta))
		strafe_delta = 0
		jump_and_land_sound()
	elif just_landed:
		just_landed = false

	# checking UI state
	if just_exited_menu:
		just_exited_menu = false
		in_menu = false
		move_and_slide()
		return

	if in_menu or is_console_open:
		velocity.x = move_toward(velocity.x, 0, player_speed_value)
		velocity.z = move_toward(velocity.z, 0, player_speed_value)
		move_and_slide()
		return

	# jumping
	bhop_frame_buffer.pop_back()
	if Input.is_action_just_pressed("jump"):
		bhop_frame_buffer.push_front(true)
		if is_on_floor():
			if just_landed && bhop_frame_buffer.any(func(b): return b):
				velocity.x = (velocity.length() * $Camera3D.project_ray_normal(screen_center).x) + (10 * velocity.normalized().x)
				velocity.z = (velocity.length() * $Camera3D.project_ray_normal(screen_center).z) + (10 * velocity.normalized().z)
				Debug.log("bhop - (frame buffer state)")
				Debug.log(str(bhop_frame_buffer))
				bhop_frame_buffer.resize(bhop_frames_value)
				bhop_frame_buffer.fill(false)
			jump_and_land_sound()
			velocity.y = jump_velocity_value
	else:
		bhop_frame_buffer.push_front(false)

	# getting x, z movement (keyboard)
	var input_dir: Vector2 = Input.get_vector("left", "right", "fwd", "bwd")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("use") && equipped != null:
		equipped.use(get_viewport().get_camera_3d().project_ray_normal(screen_center))

	# handle movement
	# flip flag if needed
	# ground speed or apply "brake" input
	if direction && is_on_floor():
		if !is_directed_on_floor:
			is_directed_on_floor = true
		if current_speed <= player_speed_value:
			velocity.x = direction.x * player_speed_value
			velocity.z = direction.z * player_speed_value
		else:
			if velocity.x * direction.x < 0:
				velocity.x = move_toward(velocity.x, 0, player_decel_on_input_value)
			if velocity.z * direction.z < 0:
				velocity.z = move_toward(velocity.z, 0, player_decel_on_input_value) 

		walking_sound(true)
	else:
		# check if state flag changed, flip sound off
		if is_directed_on_floor:
			is_directed_on_floor = false
			walking_sound(false)

	# apply friction if on any surface
	# air decel + any strafe accel if not
	if is_on_floor() || is_on_wall() || is_on_ceiling():
		velocity.x = move_toward(velocity.x, 0, player_ground_friction_value)
		velocity.z = move_toward(velocity.z, 0, player_ground_friction_value)
		velocity.y = move_toward(velocity.y, 0, player_ground_friction_value)
	else:
		velocity.x = move_toward(velocity.x, 0, air_decel_value)
		velocity.z = move_toward(velocity.z, 0, air_decel_value)
		if (!is_zero_approx(camera_motion.x)):
			if (camera_motion.x > 0 && input_dir.x > 0) || (camera_motion.x < 0 && input_dir.x < 0):
				if !in_strafe:	
					in_strafe = true
				var speed_before_strafe: float = velocity.length()
				velocity.x = (velocity.length() * $Camera3D.project_ray_normal(screen_center).x) + (air_strafe_accel_value * velocity.normalized().x)
				velocity.z = (velocity.length() * $Camera3D.project_ray_normal(screen_center).z) + (air_strafe_accel_value * velocity.normalized().z)
				strafe_delta += velocity.length() - speed_before_strafe

	# surfing acceleration
	# placeholder accel value use air strafe accel
	if is_on_wall_only():
		var wall_normal: Vector3 = get_wall_normal()	
		if direction.x * wall_normal.x < 0 || direction.z * wall_normal.z < 0:
			if !in_surf:
				in_surf = true
				surf_delta = velocity.length()
			velocity.x += air_strafe_accel_value * velocity.normalized().x
			velocity.z += air_strafe_accel_value * velocity.normalized().z
	else:
		if in_surf:
			in_surf = false
			Debug.log("surf end total speed gain:")
			Debug.log("     " + str(velocity.length() - surf_delta))
			surf_delta = 0
		
	# clamp in valid range; zero before move_and_slide call if stop pressed	
	velocity.x = clamp(velocity.x, -player_max_speed_value, player_max_speed_value)
	velocity.z = clamp(velocity.z, -player_max_speed_value, player_max_speed_value)

	if is_on_floor() && Input.is_action_just_pressed('stop'):
		velocity.x = 0
		velocity.z = 0

	current_speed = velocity.length()

	# set debug info
	if debug_node:
		var movement_info_node: TextEdit = debug_node.get_node("MovementInfo")
		
		if current_speed > recent_top_speed:
			recent_top_speed = current_speed
			velocity_when_top = velocity

		var params = [current_speed, recent_top_speed, velocity_when_top, camera_motion.x]
		movement_info_node.text = debug_node.movement_info_template % params
		
	if (move_and_slide()):
		handle_collisions()
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('devconsole'):
		get_viewport().set_input_as_handled()
		if !is_console_open:
			console_node = console_scene.instantiate()
			add_child(console_node)
			is_console_open = true
			return
		if console_node != null:
			remove_child(console_node)
			is_console_open = false
			return
	elif event.is_action_pressed('cancel'):
		if !in_menu && !is_console_open:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			in_menu = true
			menu_node = menu_scene.instantiate()
			add_child(menu_node)
			menu_node.get_child(0).get_ok_button().connect('pressed', _on_menu_ok_button_pressed)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			in_menu = false
			is_console_open = false
			just_exited_menu = true
			if menu_node:
				remove_child(menu_node)
			if console_node:
				remove_child(console_node)
	elif event.is_action_pressed('reset_recorded_metrics'):
		recent_top_speed = 0
		velocity_when_top = Vector3()
		Debug.log('metrics reset')
	elif event is InputEventKey && !is_console_open:
		if event.is_action_pressed('switch_equipped'):
				switch_equipped()
		if event.is_action_pressed('char_info'):
			if !is_char_info_open:
				char_info_node = char_info_scene.instantiate()
				add_child(char_info_node)
				is_char_info_open = true
			else:
				remove_child(char_info_node)
				is_char_info_open = false
		if event.is_action_pressed('inventory'):
			if !is_inventory_open:
				inventory_node = inventory_scene.instantiate()
				add_child(inventory_node)
				is_inventory_open = true
			else:
				remove_child(inventory_node)
				is_inventory_open = false
	return

func _on_menu_ok_button_pressed():
	if in_menu && menu_node != null:
		remove_child(menu_node)
		in_menu = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return

func _on_toggle_debug(on: bool):
	if on:
		debug_node = Debug.debug_scene.instantiate()
		add_child(debug_node)
		Debug.toggle_log()
	else:
		remove_child(debug_node)
		recent_top_speed = 0
	return
	
func jump_and_land_sound() -> void:
	if is_scene_start_jump_sound:
		is_scene_start_jump_sound = false
		return
	$Sound.stream = jump_clip
	$Sound.play()
	return

func walking_sound(start: bool) -> void:
	if !$Sound.playing && start:
		$Sound.stream = walking_clip
		$Sound.play()
	elif !start:
		$Sound.stop()
	return

func switch_equipped() -> void:
	if equipped != null && stored != null:
		$Camera3D.remove_child(equipped)
		var to_equip: Equippable = stored
		stored = equipped
		equipped = to_equip
		$Camera3D.add_child(equipped)
	return
	
func handle_proj_collision(collision: KinematicCollision3D) -> void:
	var proj: Node3D = collision.get_collider()
	was_hit.emit()
	SignalBus.projectile_hit.emit(proj.get_instance_id())
	return

func handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Node3D = collision.get_collider()
		if collider.get_instance_id() != world_ref.level_collision_id:
			if collider is Projectile:
				handle_proj_collision(collision)
	return

func add_stats_from_equipment() -> void:
	var helm: Helm = equipment.get('helm')
	var chest: Chest = equipment.get('chest')
	var pack: Pack = equipment.get('pack')
	if helm:
		max_health += helm.HP
		magic_reduction += helm.MR
	if chest:
		max_health += chest.HP
		phys_reduction += chest.PR
	if pack:
		max_health += pack.HP
		skill_cap += pack.SC
	return
	
func refresh_settings() -> void:
	player_speed_value = Settings.player_speed_value
	jump_velocity_value = Settings.jump_velocity_value
	air_decel_value = Settings.air_decel_value
	air_strafe_accel_value = Settings.air_strafe_accel_value
	player_gravity_mult_value = Settings.player_gravity_mult_value
	player_ground_friction_value = Settings.player_ground_friction_value
	player_decel_on_input_value = Settings.player_decel_on_input_value
	bhop_frames_value = Settings.bhop_frames_value
	return
