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
	player_node = world.get_node_or_null("Player")
	if player_node:
		player_location = player_node.global_position
	SignalBus.apply_effects.connect(_on_apply_effects)
	hp_bar = get_node("HealthBar")
	return

func _physics_process(delta: float) -> void:		
	setup_behavior(maintain_pc_los, player_location, follow_player)
	simple_velocity(delta)
	if move_and_slide():
		handle_collisions()
	return

func handle_proj_collision(collision: KinematicCollision3D) -> void:
	var collided_proj: Node3D = collision.get_collider()
	SignalBus.projectile_hit.emit(collided_proj.get_instance_id(), get_instance_id())
	return

func handle_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Node3D = collision.get_collider()
		if collider.get_instance_id() != world.level_collision_id:
			if collider is Projectile:
				handle_proj_collision(collision)
	return
		
func _on_apply_effects(target_id: int, effects: Array[Effect]) -> void:
	if target_id == get_instance_id():
		for effect: Effect in effects:
			if effect.type == Effect.Type.DAMAGE:
				var dmg: int = randi_range(effect.min_dmg, effect.max_dmg)
				hp -= dmg
				if hp < 0: hp = 0
				hp_bar.texture.gradient.set_offset(1, ((max_hp+.004) - hp)/max_hp)
	return

func move_towards_player(_location) -> void:
	if _location:
		direction = global_position.direction_to(_location)
	return

func set_player_location(_location: Vector3) -> void:
	player_location = _location
	return

func simple_velocity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if direction && !frozen:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	return

func setup_behavior(_los: bool , _location: Vector3, _follow: bool) -> void:
	if _los && _location:
		look_at(_location)

	if _location:
		hp_bar.look_at(_location)
	
	if _follow:
		print("follow player")
		move_towards_player(_location)
	return
