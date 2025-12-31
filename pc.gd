extends CharacterBody3D

const SPEED: float = 5.0;
const JUMP_VELOCITY: float = 4.5;

const console_scene: Resource = preload("res://dev_console.tscn");
var console_node: Control = null;
var is_console_open: bool = false;

const menu_scene: Resource = preload("res://menu.tscn");
var menu_node: Control = null;
var in_menu: bool = true;
var just_exited_menu: bool = true;

var debug_node: Control = null;

@export var gun: Gun;

func _ready() -> void: 
		Debug.connect("toggle_debug", _on_toggle_debug);
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
		jump_sound();
		velocity.y = JUMP_VELOCITY;

	var input_dir := Input.get_vector("left", "right", "fwd", "bwd");
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	#TODO need to replace hardcoded values when adding resolution adjustment option
	if Input.is_action_just_pressed("use"):
		gun.use(get_viewport().get_camera_3d().project_ray_normal(Vector2(1920.0/2, 1080.0/2))); 

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
					menu_node.get_child(0).get_child(2).connect("pressed", _on_menu_ok_button_pressed);
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
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

func _on_toggle_debug(on: bool):
	if on:
		debug_node = Debug.debug_scene.instantiate();
		add_child(debug_node);
	else:
		remove_child(debug_node);
	return;
	
#TODO set $Sound.stream before playing (when there are multiple available effects	
func jump_sound() -> void:
	$Sound.play()
	return;
