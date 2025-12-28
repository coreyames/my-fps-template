class_name Proj
extends AnimatableBody3D

# 10 is really fast
const INITIAL_SPEED = 5;

var direction: Vector3;

enum Status {
	LOADED,
	FIRE,
	TRAVELING,
}

var status: Status = Status.LOADED;

func _ready() -> void:
	$CollisionShape3D.scale = Vector3(.05, .05, .05);

func _physics_process(delta: float) -> void:
	if (status == Status.FIRE):
		status = Status.TRAVELING;
	elif (status == Status.TRAVELING):
		move_and_collide(direction);	

func fire(_direction: Vector3) -> void:
	direction = _direction;
	status = Status.FIRE;
