class_name GUN_AssaultRifle extends Gun	

const PROJ_SPAWN_Z_OFFSET = 0.57
const PROJ_SPAWN_Y_OFFSET = 0.077

const AR_DEFAULT_MAX_LOADED: int = 30
const AR_DEFAULT_MAX_RESERVE: int = 90

func _ready() -> void:
	max_loaded = AR_DEFAULT_MAX_LOADED
	max_reserve = AR_DEFAULT_MAX_RESERVE
	sound_clip = DEFAULT_SHOOT_SOUND
	$Sound.stream = sound_clip
	return

func shoot(direction: Vector3) -> void:
	var projectile: Proj = ammo_scene.instantiate()
	projectile.position = global_position
	projectile.rotation = global_rotation
	projectile.translate_object_local(Vector3(0, PROJ_SPAWN_Y_OFFSET, PROJ_SPAWN_Z_OFFSET))
	get_node("/root").add_child(projectile)
	$AnimationPlayer.play("use")
	$Sound.play()
	used.emit()
	projectile.fire(direction)
	return
