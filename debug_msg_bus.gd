extends Node

signal msg_ready(msg: String)
signal toggle_debug(on: bool)

const debug_scene: Resource = preload("res://debug_hud.tscn");
var is_on: bool = false;
var print_to_stdout: bool = true;

func log(msg: String) -> void:
	if is_on:
		emit_signal("msg_ready", msg);
	if print_to_stdout:
		print(msg);
	return;
	
func toggle() -> bool:
	is_on = !is_on;
	emit_signal("toggle_debug", is_on);
	return is_on;
