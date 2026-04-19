extends Control

func _ready() -> void:
	Debug.msg_ready.connect(_on_log_message)
	Debug.toggle_debug_log.connect(_on_toggle_log)
	Debug.toggle_debug_movement.connect(_on_toggle_movement)
	$Log.visible = Debug.show_log
	$MovementInfo.visible = Debug.show_movement
	return
		
func _on_log_message(msg: String) -> void:
	$Log.text += msg + '\n'
	return
	
func _on_toggle_log(show_log: bool) -> void: 
	$Log.visible = show_log
	return
	
func _on_toggle_movement(show_movement: bool) -> void: 
	$MovementInfo.visible = show_movement
	return
