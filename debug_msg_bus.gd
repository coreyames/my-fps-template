extends Node

signal msg_ready(msg: String)

const debug_scene: Resource = preload("res://debug_hud.tscn");
var debug_node: Node;
var is_on: bool = false;

func debug(msg: String) -> void:
	if is_on:
		emit_signal("msg_ready", msg);
	return;
	
func on() ->  void:
	debug_node = debug_scene.instantiate();
	add_child(debug_node);
	is_on = true;
	
func off() -> void:
	remove_child(debug_node);
	debug_node = null;
	is_on = false;
	
func toggle() -> void:
	if is_on:
		off();
	else:
		on();
	return;
