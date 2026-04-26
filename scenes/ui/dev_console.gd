extends Control

@onready var console: TextEdit = $Console
@onready var input: LineEdit = $LineEdit

var history_offset: int = 1

var prompt: String = '> '

func _ready() -> void:
	console.editable = false
	input.caret_blink = true
	input.keep_editing_on_text_submit = true
	input.clear()
	console.text = prompt
	input.edit()
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up_arrow"):
		input.clear()
		print(history_offset)
		var history_length: int = Debug.console_history.size()
		if (history_length > 0):
			input.text = Debug.console_history.get(history_length - history_offset)
			history_offset += 1
			if history_offset > history_length:
				history_offset = 1
	return
	
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
	Debug.console_history.append(input_line)
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
		"player_gravity_multiplier":
			var value: String = check_for_param(line_split_array)
			if value.length() > 0:
				Settings.player_gravity_multipler_value = float(value)
				get_tree().call_group("settings_dependent", "refresh_settings")
				console.text += "updated"
		"history":
			for _cmd: String in Debug.console_history:
				console.text += _cmd + '\n'
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
		
	
