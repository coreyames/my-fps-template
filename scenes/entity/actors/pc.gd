extends CharacterBody3D

signal was_hit

var world: Node3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const AIR_DECEL_START: float = 1.0/(SPEED*SPEED*10*10) # TODO idfk lol
const AIR_STRAFE_ACCEL: float = 0.5

var is_scene_ready_jump: bool = true
var is_directed_on_floor: bool = false
var was_airborne: bool = false

const walking_clip: AudioStreamMP3 = preload("res://audio/walking.mp3")
const jump_clip: AudioStreamMP3 = preload("res://audio/jump.mp3")

const console_scene: Resource = preload("res://scenes/ui/dev_console.tscn")
var console_node: Control = null
var is_console_open: bool = false

const menu_scene: Resource = preload("res://scenes/ui/menu.tscn")
var menu_node: Control = null
var in_menu: bool = true
var just_exited_menu: bool = true
var debug_node: Control = null

# gun_scenes here serve as tmp defaults; when accessing char, equip scenes are actual property
const gun_ar_scene: Resource = preload('res://scenes/entity/objects/equippable/gun_ar.tscn')
const gun_ar2_scene: Resource = preload('res://scenes/entity/objects/equippable/gun_ar2.tscn')
var equip1_scene: Resource = gun_ar_scene
var equip2_scene: Resource = gun_ar2_scene

@export var equipped: Equippable
var stored: Equippable
var viewmodel: Transform3D

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

var equipment: Dictionary[String, Equippable] = {
	"w1": null,
	"w2": null,
	"helm": null,
	"chest": null,
	"pack": null
}

var skills: Dictionary[int, Skill] = {}

func _ready() -> void: 
	world = get_parent()
	Debug.connect("toggle_debug", _on_toggle_debug)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if (equip2_scene != null):
		stored = equip2_scene.instantiate()
	viewmodel = equipped.transform
	stored.transform = viewmodel
	$Sound.volume_db = -15
	equipment.set("w1", equipped)
	equipment.set("w2", stored)
	add_stats_from_equipment()
	for i in range(0, skill_cap):
		skills.set(i, null)
	return

func _physics_process(delta: float) -> void:
	var camera_motion: Vector2 = $Camera3D.motion
	if not is_on_floor():
		velocity += get_gravity() * delta
		if !was_airborne:
			was_airborne = true
	elif was_airborne:
		was_airborne = false
		jump_and_land_sound() 

	if just_exited_menu:
		just_exited_menu = false
		in_menu = false
		move_and_slide()
		return

	if in_menu or is_console_open:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_and_land_sound()
		velocity.y = JUMP_VELOCITY

	var input_dir: Vector2 = Input.get_vector("left", "right", "fwd", "bwd")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#TODO need to replace hardcoded values when adding resolution adjustment option
	if Input.is_action_just_pressed("use") && equipped != null:
		equipped.use(get_viewport().get_camera_3d().project_ray_normal(Vector2(1920.0/2, 1080.0/2)))

	if direction && is_on_floor():
		if !is_directed_on_floor:
			is_directed_on_floor = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		walking_sound(true)
	else:
		if is_directed_on_floor:
			is_directed_on_floor = false
			walking_sound(false)

		if !direction && !is_on_floor():
			velocity.x = move_toward(velocity.x, 0, AIR_DECEL_START)
			velocity.z = move_toward(velocity.z, 0, AIR_DECEL_START)
		elif direction && !is_on_floor(): #TODO logic here
			velocity.x = move_toward(velocity.x, 0, AIR_DECEL_START)
			velocity.z = move_toward(velocity.z, 0, AIR_DECEL_START)
			if (!is_zero_approx(camera_motion.x)):
				if (camera_motion.x > 0 && input_dir.x > 0) || (camera_motion.x < 0 && input_dir.x < 0):
					velocity.x += AIR_STRAFE_ACCEL * direction.x
					velocity.z += AIR_STRAFE_ACCEL * direction.z
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if debug_node:
		var movement_info: TextEdit = debug_node.get_node("MovementInfo")
		movement_info.text = str(velocity)
		
	if (move_and_slide()):
		handle_collisions()
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("devconsole"):
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
	else:
		if event is InputEventKey:
			if event.is_action_pressed('cancel'):
				if !in_menu:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					in_menu = true
					menu_node = menu_scene.instantiate()
					add_child(menu_node)
					menu_node.get_child(0).get_child(2).connect("pressed", _on_menu_ok_button_pressed)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					in_menu = false
					just_exited_menu = true
					remove_child(menu_node)
			if event.is_action_pressed('switch_equipped'):
					switch_equipped()
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
	else:
		remove_child(debug_node)
	return
	
func jump_and_land_sound() -> void:
	if is_scene_ready_jump:
		is_scene_ready_jump = false
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
	var collider: Node3D = collision.get_collider()
	Debug.log(str(collider))
	was_hit.emit()
	SignalBus.projectile_hit.emit(collider.get_instance_id())
	return

func handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Node3D = collision.get_collider()
		if collider.get_instance_id() != world.level_collision_id:
			if collider is Projectile:
				handle_proj_collision(collision)
	return

func add_stats_from_equipment() -> void:
	var helm: Helm = equipment.get("helm")
	var chest: Chest = equipment.get("chest")
	var pack: Pack = equipment.get("pack")
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
