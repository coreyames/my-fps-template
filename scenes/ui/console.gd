extends Control

@export var console: TextEdit
@export var input: LineEdit

@export_group("devconsole_settings")
@export var prompt: String = '> '

func _ready() -> void:
	console.editable = false
	input.caret_blink = true
	input.keep_editing_on_text_submit = true
	input.clear()
	console.text = prompt
	input.edit()
	return

func _process(delta: float) -> void:
	pass
	
func _on_line_edit_text_submitted(submitted: String) -> void:
	# log cmd up top, new line, process and add output to console.text
	console.text += submitted + '\n'
	process_input(submitted)
	# newline and add prompt to move on for next cmd
	console.text += '\n' + prompt
	input.clear()
	input.set_caret_column(0)
	return

func clear() -> void:
	input.clear()
	input.set_caret_column(0)
	console.clear()
	console.set_caret_column(0, false)
	console.set_caret_line(0, false)
	return

# console.text will be on a newline
func process_input(input_line: String) -> void:
	var line_split_array = input_line.split(" ", true, 1)
	if line_split_array.size() < 1:
		return
	var cmd = line_split_array.get(0)
	match cmd:
		"echo":
			if (line_split_array.size() == 2):
				console.text += line_split_array.get(1)
		"debug":
			Debug.toggle()
		"debug_log":
			Debug.toggle_log()
		"debug_movement":
			Debug.toggle_movement()
		"mouse_sensitivity":
			var value: String = check_for_param(line_split_array)
			if value.length() > 0:
				Settings.mouse_sensitivity_value = float(value)
				get_tree().call_group("settings_dependent", "refresh_settings")
				console.text += "updated"
		"air_strafe_accel":
			var value: String = check_for_param(line_split_array)
			if value.length() > 0:
				Settings.air_strafe_accel_value = float(value)
				get_tree().call_group("settings_dependent", "refresh_settings")
				console.text += "updated"
		"air_decel":
			var value: String = check_for_param(line_split_array)
			if value.length() > 0:
				Settings.air_decel_value = float(value)
				get_tree().call_group("settings_dependent", "refresh_settings")
				console.text += "updated"
		"player_speed":
			var value: String = check_for_param(line_split_array)
			if value.length() > 0:
				Settings.player_speed_value = float(value)
				get_tree().call_group("settings_dependent", "refresh_settings")
				console.text += "updated"
		"quit":
			get_tree().quit()
		_:
			console.text += "unrecognized command"
	return

func check_for_param(split_array: Array[String]) -> String:
	if split_array.size() != 2:
		console.text += "invalid parameters"
		return ""
	return split_array.get(1)
		
	
