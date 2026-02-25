extends CharacterBody3D

signal was_hit

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const dir_actions: Array[StringName] =  ["ui_left", "ui_right", "ui_up", "ui_down"]
		
var chance_to_change: float = .5
var chance_to_jump: float = .3
var dir_entropy: float = 0
var jump_entropy: float = 0	
var current_action: StringName = "ui_up"
var input_dir: Vector2 = Vector2(0.0, 0.0)
var to_jump: bool = false
var stand_still: bool = true

var maintain_pc_los: bool = true
var player_location: Vector3
var player_node: CharacterBody3D
var world: Node3D

func _ready() -> void:
	world = get_parent()
	player_node = world.get_node('Player')
	player_location = player_node.global_position
	current_action = dir_actions.pick_random()
	return

func generate_input() -> void:
	var dir_chance = chance_to_change * dir_entropy
	var dir_roll = randf()
	if dir_roll > 1 - dir_chance:
		current_action = dir_actions.pick_random()
		dir_entropy = 0
	else:
		dir_entropy += .001
		
	var jump_chance = chance_to_jump * jump_entropy
	var jump_roll = randf()
	if jump_roll > 1 - jump_chance:
		to_jump = true
		jump_entropy = 0
	else:
		jump_entropy += .001
		
	match current_action:
		"ui_left":
			input_dir = Vector2(-1,0)
		"ui_right":
			input_dir = Vector2(1,0)
		"ui_up":
			input_dir = Vector2(0,1)
		"down":
			input_dir = Vector2(0,-1)
	return

func _physics_process(delta: float) -> void:
	player_location = player_node.global_position
	
	if maintain_pc_los:
		look_at(player_location)
	
	generate_input()
	
	if stand_still:
		to_jump = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if to_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		to_jump = false

	# Get the input direction and handle the movement/deceleration.
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && !stand_still:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if (move_and_slide()):
		handle_collision()
	return

func handle_collision() -> void:
	var cid: int = get_last_slide_collision().get_collider_id()
	if cid != world.level_collision_id:
		Debug.log(str(cid))
		#was_hit.emit(cid)
		SignalBus.projectile_hit.emit(cid)
	return	
