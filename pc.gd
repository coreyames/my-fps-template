extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

const console_scene: Resource = preload("res://dev_console.tscn");
var console_node: Control = null;
var is_console_open: bool = false;

const menu_scene: Resource = preload("res://menu.tscn");
var menu_node: Control = null;
var in_menu: bool = true;
var just_exited_menu: bool = true;

@export var gun: Gun;

func _ready() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		return;

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta;

	if just_exited_menu:
		just_exited_menu = false;
		in_menu = false;
		move_and_slide();
		return;

	if in_menu or is_console_open:
		velocity.x = move_toward(velocity.x, 0, SPEED);
		velocity.z = move_toward(velocity.z, 0, SPEED);
		move_and_slide();
		return;

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY;

	var input_dir := Input.get_vector("left", "right", "fwd", "bwd");
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	if Input.is_action_just_pressed("use"):
		pass
		#gun.use(Vector3(get_viewport().get_camera_3d().transform.basis.z; 

	if direction:
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED);
		velocity.z = move_toward(velocity.z, 0, SPEED);
	move_and_slide();
	return;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("devconsole"):
		get_viewport().set_input_as_handled();
		if !is_console_open:
			console_node = console_scene.instantiate();
			add_child(console_node);
			is_console_open = true;
			return;
		if console_node != null:
			remove_child(console_node);
			is_console_open = false;
			return;
			
	else:
		if event is InputEventKey:
			if event.is_action_pressed('cancel'):
				if !in_menu:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
					in_menu = true;
					menu_node = menu_scene.instantiate();
					add_child(menu_node);
					#print(menu_node.get_tree_string_pretty()); # check tree
					menu_node.get_child(0).get_child(2).connect("pressed", _on_menu_ok_button_pressed);
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					in_menu = false;
					just_exited_menu = true;
					remove_child(menu_node);
	return;

func _on_menu_ok_button_pressed():
	if in_menu && menu_node != null:
		remove_child(menu_node);
		in_menu = false;
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	return;
		
