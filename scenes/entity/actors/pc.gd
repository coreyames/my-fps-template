extends CharacterBody3D

signal was_hit(effects: Array[Effect])

var world_ref: Node3D
var viewport_size_x: float
var viewport_size_y: float
var screen_center: Vector2

#
# PLAYER INFORMATION
#
const NAME_DEFAULT: String = "PLAYER"
var player_name: String = NAME_DEFAULT
var xp: int

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
var player_bhop_accel_value: float = Settings.player_bhop_accel_value
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
var hud_node: Control

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

#
# STATS
#
var base_stats: Dictionary[String, int] = {
	"HP": 100, # max health
}

var max_hp: int = base_stats.get("HP")
var hp: int = max_hp

#
# FLAGS, NODE STATUS, METRICS, DEBUG 
#
var current_speed: float = 0
var recent_top_speed: float = 0
var velocity_when_top: Vector3

var in_strafe: bool = false
var in_strafe_left: bool = false
var in_strafe_right: bool = false
var strafe_delta: float = 0
var in_surf: bool = false
var surf_delta: float = 0

var just_landed: bool = false
var bhop_frame_buffer: Array[bool]
var is_air_strafe_valid: bool = false

var is_reloading: bool = false

func _ready() -> void: 
	world_ref = get_parent()
	SignalBus.player_instance_id = get_instance_id()
	viewport_size_x = get_viewport().get_visible_rect().size.x
	viewport_size_y = get_viewport().get_visible_rect().size.y
	screen_center = Vector2(viewport_size_x/2, viewport_size_y/2)

	add_to_group("settings_dependent")
	Debug.toggle_debug.connect( _on_toggle_debug)
	SignalBus.affect_player.connect(_on_affect_player)
	SignalBus.award_xp.connect(_on_award_xp)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Sound.volume_db = -15
	floor_stop_on_slope = false

	if (equip2_scene != null):
		stored = equip2_scene.instantiate()
	equipped = $Camera3D/Equipped
	viewmodel = equipped.transform
	stored.transform = viewmodel

	hud_node = hud_scene.instantiate()
	add_child(hud_node)

	equipped.animation_player_node.animation_finished.connect(_on_reload_anim_finished)

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
		if is_on_floor():
			if just_landed || bhop_frame_buffer.any(func(b: bool) -> bool: return b):
				velocity.x += player_bhop_accel_value * velocity.normalized().x
				velocity.z += player_bhop_accel_value * velocity.normalized().z
				Debug.log("bhop - (frame buffer state recent->oldest)")
				Debug.log(str(bhop_frame_buffer))
				bhop_frame_buffer.resize(bhop_frames_value)
				bhop_frame_buffer.fill(false)
			jump_and_land_sound()
			velocity.y = jump_velocity_value
		else:
			bhop_frame_buffer.push_front(true)
	else:
		bhop_frame_buffer.push_front(false)

	# getting x, z movement (keyboard)
	var input_dir: Vector2 = Input.get_vector("left", "right", "fwd", "bwd")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("use") && equipped != null && !is_reloading && hud_node.loaded > 0:
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

	var xz_velocity: Vector2 = Vector2(velocity.x, velocity.z).normalized()
	var xz_camera: Vector2 = Vector2($Camera3D.project_ray_normal(screen_center).x, $Camera3D.project_ray_normal(screen_center).z)
	var xz_dot: float = xz_velocity.dot(xz_camera)

	if debug_node:
			var params: Array = [xz_velocity, xz_camera, xz_velocity.dot(xz_camera), str(is_air_strafe_valid)]
			debug_node.get_node('Temp').text = "vel %.2v\ncam %.2v\n dot %.2f\n %s" % params

	# apply friction if on any surface
	# air decel + any strafe accel if not
	# flip flag for air strafing if on ground camera has no forward movement
	# idk if this not being IFF isonfloor but i guess we will see
	if is_on_floor() || is_on_wall() || is_on_ceiling():
		velocity.x = move_toward(velocity.x, 0, player_ground_friction_value)
		velocity.z = move_toward(velocity.z, 0, player_ground_friction_value)

		if in_strafe_right:
			print('STRAFE RIGHT: +%.3f' % [strafe_delta])
			in_strafe_right = false
		
		if in_strafe_left:
			print('STRAFE LEFT: +%.3f' % [strafe_delta])
			in_strafe_left = false
		
		strafe_delta = 0
			
		if !is_zero_approx(xz_dot):
			is_air_strafe_valid = true
		else:
			is_air_strafe_valid = false

	else:
		velocity.x = move_toward(velocity.x, 0, air_decel_value)
		velocity.z = move_toward(velocity.z, 0, air_decel_value)
		velocity.y = move_toward(velocity.y, 0, air_decel_value)
		
		var strafe_look_match: bool = (camera_motion.x > 0 && input_dir.x > 0) || (camera_motion.x < 0 && input_dir.x < 0)
		if abs(camera_motion.x) > 0.03 && is_air_strafe_valid && strafe_look_match: 
			if input_dir.x > 0:
				if in_strafe_left:
					print('STRAFE LEFT: +%.3f' % [strafe_delta])
					strafe_delta = 0

				if !in_strafe_right: 
					in_strafe_right = true
					strafe_delta = 0
					print("air strafe right started")
				in_strafe_left = false

			else:
				if in_strafe_right:
					print('STRAFE RIGHT: +%.3f' % [strafe_delta])
					strafe_delta = 0

				if !in_strafe_left: 
					in_strafe_left = true
					strafe_delta = 0
					print("air strafe left started")
				in_strafe_right = false
		
			var start: float = velocity.length()
			var cam_normal: Vector3 = get_camera_normal()
			velocity.x += air_strafe_accel_value * cam_normal.x				
			velocity.z += air_strafe_accel_value * cam_normal.z
			strafe_delta += velocity.length() - start

	# surfing acceleration
	# placeholder accel value use air strafe accel
	if is_on_wall_only():
		var wall_normal: Vector3 = get_wall_normal()	
		if direction.x * wall_normal.x < 0 || direction.z * wall_normal.z < 0:
			if !in_surf:
				in_surf = true
				Debug.log("surf started")
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

		var params: Array = [current_speed, recent_top_speed, velocity_when_top, camera_motion.x]
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
		if event.is_action_pressed('reload'):
			if !is_char_info_open && !is_inventory_open && !is_reloading:
				if hud_node.loaded < equipped.max_loaded && hud_node.reserve > 0:
					is_reloading = true
					equipped.reload_anim()
	return

func _on_menu_ok_button_pressed() -> void:
	if in_menu && menu_node != null:
		remove_child(menu_node)
		in_menu = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return

func _on_toggle_debug(on: bool) -> void:
	if on:
		debug_node = Debug.debug_scene.instantiate()
		add_child(debug_node)
		Debug.toggle_log()
	else:
		remove_child(debug_node)
		recent_top_speed = 0
	return
	
func _on_affect_player(effects: Array[Effect]) -> void:
	for effect: Effect in effects:
		if effect.type == Effect.Type.DAMAGE:
			var dmg: int = randi_range(effect.min_dmg, effect.max_dmg)
			hp -= dmg
			effect.dmg_dealt = dmg
			if hp < 0: hp = 0
	was_hit.emit(effects)
	return

func _on_award_xp(amount: int) -> void:
	xp += amount
	var xp_status: Label = hud_node.get_node_or_null("Status/XP")
	print(xp_status)
	xp_status.text = str(xp)
	print (xp_status.text)
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
	SignalBus.projectile_hit.emit(proj.get_instance_id(), get_instance_id())
	return

func handle_collisions() -> void:
	for i: int in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Node3D = collision.get_collider()
		if collider.get_instance_id() != world_ref.level_collision_id:
			if collider is Projectile:
				handle_proj_collision(collision)
	return

func _on_reload_anim_finished(anim_name: StringName) -> void:
	if anim_name == "reload":
		var used: int = equipped.max_loaded - hud_node.loaded
		var to_loaded_val: int = equipped.max_loaded if hud_node.reserve >= used else hud_node.reserve + hud_node.loaded
		hud_node.update_ammo_count(to_loaded_val, hud_node.reserve - (to_loaded_val - hud_node.loaded))
		is_reloading = false
	return
	
func refresh_settings() -> void:
	player_speed_value = Settings.player_speed_value
	jump_velocity_value = Settings.jump_velocity_value
	air_decel_value = Settings.air_decel_value
	air_strafe_accel_value = Settings.air_strafe_accel_value
	player_gravity_mult_value = Settings.player_gravity_mult_value
	player_ground_friction_value = Settings.player_ground_friction_value
	player_decel_on_input_value = Settings.player_decel_on_input_value
	player_bhop_accel_value = Settings.player_bhop_accel_value
	bhop_frames_value = Settings.bhop_frames_value
	return

func get_camera_normal() -> Vector3:
	return $Camera3D.project_ray_normal(screen_center)
	
