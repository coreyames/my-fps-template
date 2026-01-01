extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const dir_actions: Array[StringName] =  ["ui_left", "ui_right", "ui_up", "ui_down"]
	
var chance_to_change = .5;
var chance_to_jump = .3;	
var dir_entropy: float = 0;
var jump_entropy: float = 0;	
var current_dir: StringName = "ui_up";
var change_dir: bool = false;
var to_jump: bool = false

func _ready() -> void:
	current_dir = dir_actions.pick_random();
	return;

func generate_input() -> void:
	var dir_chance = chance_to_change * dir_entropy;
	var dir_roll = randf();
	if dir_roll > 1 - dir_chance:
		change_dir = true;
		
		
	
			
	
	
	
	# entropy affects chance for action
	# previous action affects next action chance
	#  	for instance, switching direction will reset entropy, making staying direction more likely at first
	# 
	return;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if to_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
