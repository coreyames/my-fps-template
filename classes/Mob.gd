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
var xp_reward: int = 10
var max_hp: int = 100
var speed: float = 4
var reaccel: float = .1

var effects: Array[Effect]

# mob status
var hp: int = max_hp
var hp_bar: Sprite3D
var knock_back: bool = false
var recovery: bool = false

# mob action or behvaior 
var pacifist: bool = false
var maintain_pc_los: bool = true
var follow_player: bool = false
var frozen: bool = false
var direction: Vector3
var screen_center: Vector2

func _ready() -> void:
	world = get_tree().current_scene
	var viewport_size_x = get_viewport().get_visible_rect().size.x
	var viewport_size_y = get_viewport().get_visible_rect().size.y
	screen_center = Vector2(viewport_size_x/2, viewport_size_y/2)
	player_node = world.get_node_or_null("Player")
	if player_node:
		player_location = player_node.global_position
	SignalBus.apply_effects.connect(_on_apply_effects)
	hp_bar = get_node("HealthBar")
	return

func _physics_process(delta: float) -> void:
	if player_node:
		player_location = player_node.global_position
		if maintain_pc_los:
			look_at(player_location)
	
	if follow_player && player_location:
		direction = global_position.direction_to(player_location)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if knock_back && !recovery:
		velocity = speed * -direction * 2
		recovery = true
	elif knock_back && recovery:
		if velocity.length() == 0:
			recovery = false
			knock_back = false
		else:
			velocity.x = move_toward(velocity.x, 0, reaccel)
			velocity.z = move_toward(velocity.z, 0, reaccel)
	elif direction && !frozen:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)	

	if move_and_slide():
		handle_collisions()
	return

func handle_proj_collision(collision: KinematicCollision3D) -> void:
	var collided_proj: Node3D = collision.get_collider()
	SignalBus.projectile_hit.emit(collided_proj.get_instance_id(), get_instance_id())
	return

func handle_other_collision(collision: KinematicCollision3D) -> void:
	var collided_with: Node3D = collision.get_collider()
	if player_node && collided_with.get_instance_id() == SignalBus.player_instance_id:
		SignalBus.affect_player.emit(effects)
		knock_back = true
	return

func handle_collisions() -> void:
	var has_collided_with: Array[int] = []
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Node3D = collision.get_collider()
		if collider.get_instance_id() != world.level_collision_id:
			if collider is Projectile:
				handle_proj_collision(collision)
			else:
				if !has_collided_with.has(collision.get_collider_id()):
					handle_other_collision(collision)
					has_collided_with.append(collision.get_collider_id())
	return
		
func _on_apply_effects(target_id: int, _effects: Array[Effect]) -> void:
	if target_id == get_instance_id():
		for effect: Effect in _effects:
			if effect.type == Effect.Type.DAMAGE:
				var dmg: int = randi_range(effect.min_dmg, effect.max_dmg)
				hp -= dmg
				effect.dmg_dealt = dmg
				if hp < 0:
					if player_node:
						SignalBus.award_xp.emit(xp_reward)
					queue_free()
				else:
					hp_bar.texture.gradient.set_offset(1, ((max_hp+.004) - hp)/max_hp)
	return
