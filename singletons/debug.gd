extends Node

# Global access as Debug

signal msg_ready(msg: String)
signal toggle_debug(on: bool)
signal toggle_debug_log(on: bool)
signal toggle_debug_movement(on: bool)
signal toggle_debug_draw_trail(on: bool)

const debug_scene: Resource = preload("res://scenes/ui/debug_hud.tscn")
var is_on: bool = false
var show_log: bool = false
var show_movement: bool = false
var draw_trail: bool = false
var print_to_stdout: bool = true

var console_history: Array[String] = []

func log(msg: String) -> void:
	if is_on:
		msg_ready.emit(msg)
	if print_to_stdout:
		print(msg)
	return
	
func toggle() -> bool:
	is_on = !is_on
	show_log = is_on
	show_movement = is_on
	toggle_debug.emit(is_on)
	return is_on
	
func toggle_log() -> bool:
	show_log = !show_log
	toggle_debug_log.emit(show_log)
	return show_log

func toggle_movement() -> bool:
	show_movement = !show_movement
	toggle_debug_movement.emit(show_movement)
	return show_movement
	
func toggle_draw_trail() -> bool:
	draw_trail = !draw_trail
	toggle_debug_draw_trail.emit(draw_trail)
	return draw_trail