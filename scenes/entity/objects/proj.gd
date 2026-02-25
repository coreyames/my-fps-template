class_name Proj
extends AnimatableBody3D

const SPEED = 60

var direction: Vector3
var motion: Vector3

enum Status {
	LOADED,
	FIRE,
	TRAVELING,
	DONE
}

var status: Status = Status.LOADED

func _ready() -> void:
	sync_to_physics = false
	SignalBus.projectile_hit.connect(_on_projectile_hit)
	$CollisionShape3D.scale = Vector3(.05, .05, .05)
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
	#Debug.log("fired proj")
	return

func _on_projectile_hit(cid: int) -> void:
	if cid == get_instance_id():  
		status = Status.DONE
	return
