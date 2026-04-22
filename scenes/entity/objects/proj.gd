class_name Projectile
extends AnimatableBody3D

#
# PHYSICS
#
const SPEED = 60

var direction: Vector3
var motion: Vector3

#
# PHASE TRACKING
#
enum Status {
	LOADED,
	FIRE,
	TRAVELING,
	DONE
}

var status: Status = Status.LOADED

var effects: Array[Effect] = []

func _ready() -> void:
	sync_to_physics = false
	SignalBus.projectile_hit.connect(_on_projectile_hit)
	$CollisionShape3D.scale = Vector3(.05, .05, .05)
	var effect: Effect = Effect.new()
	effect.type = Effect.Type.DAMAGE
	effect.min_dmg = 5
	effect.max_dmg = 15
	effects.append(effect)
	return

func _process(delta: float) -> void:
	if status == Status.FIRE:
		status = Status.TRAVELING
	elif status == Status.TRAVELING:
		motion += Vector3(0, get_gravity().y * delta *.001 , 0)
		move_and_collide(motion)
	elif status == Status.DONE:
		queue_free()
		return

func fire(_direction: Vector3) -> void:
	direction = _direction
	motion = direction * get_process_delta_time() * SPEED
	status = Status.FIRE
	return

func _on_projectile_hit(proj_id: int, collider_id: int) -> void:
	if proj_id == get_instance_id():  
		status = Status.DONE
		SignalBus.apply_effects.emit(collider_id, effects)
	return
