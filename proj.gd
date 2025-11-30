class_name Proj
extends AnimatableBody3D

const INITIAL_SPEED = 10;

var direction: Vector3;

enum Status {
	LOADED,
	FIRE,
	TRAVELING,
}

var status: Status = Status.LOADED;

func _ready() -> void:
	$CollisionShape3D.scale = Vector3(.1, .1, .1);

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if (status == Status.FIRE):
		constant_linear_velocity.x = INITIAL_SPEED;
		constant_linear_velocity.z = INITIAL_SPEED;
		status = Status.TRAVELING;
	elif (status == Status.TRAVELING):
		constant_linear_velocity += get_gravity() * delta;
	move_and_collide(direction);

func fire(_direction: Vector3) -> void:
	direction = _direction;
	status = Status.FIRE;
