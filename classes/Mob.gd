class_name Mob extends CharacterBody3D

# tier enum
enum { NORMAL, LEADER, BOSS }

# world refs, etc.
var world: Node3D
var player_location: Vector3
var player_node: CharacterBody3D

# mob info, stats
var tier: int = NORMAL
var mob_name: String = "default"
var max_hp: int = 100
var speed: float = 4

# mob status
var hp: int = max_hp
var hp_bar: Sprite3D

# mob action or behvaior 
var pacifist: bool = false
var maintain_pc_los: bool = true
var follow_player: bool = true
var frozen: bool = false
var direction: Vector3

func _ready() -> void:
	world = get_tree().current_scene
	player_node = world.get_node("Player")
	if player_node:
		player_location = player_node.global_position
	return

func _process_physics(delta: float) -> void:
	if !player_node:
		player_node = world.get_node("Player")
		if player_node:
			player_location = player_node.global_position
		
	if maintain_pc_los:
		look_at(player_location)

	hp_bar.look_at(player_location)
	
	if follow_player:
		move_towards_player()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction && !frozen:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	return

func move_towards_player() -> void:
	if player_location:
		direction = global_position.direction_to(player_location)
	return