class_name Proj
extends AnimatableBody3D

const SPEED = 60;

var direction: Vector3;
var motion: Vector3;

enum Status {
	LOADED,
	FIRE,
	TRAVELING,
	DONE
}

var status: Status = Status.LOADED;

func _ready() -> void:
	$CollisionShape3D.scale = Vector3(.05, .05, .05);
	return;

func _process(delta: float) -> void:
	if (status == Status.FIRE):
		status = Status.TRAVELING;
	elif (status == Status.TRAVELING):
		motion += Vector3(0, get_gravity().y * delta *.001 , 0);
	elif (status == Status.DONE):
		queue_free();
		return;
	handle_collision(move_and_collide(motion));
	return

func fire(_direction: Vector3) -> void:
	direction = _direction;
	motion = direction * get_process_delta_time() * SPEED;
	status = Status.FIRE;
	Debug.log("fired proj");
	return;

func handle_collision(collision: KinematicCollision3D) -> bool:
	if collision == null:
		return false;
	Debug.log(str(collision.get_collider_id()));
	status = Status.DONE;
	return true;
	
	
