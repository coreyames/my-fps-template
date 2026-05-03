extends Control

const movement_info_template: String = "
   Speed: %.2f
     Top: %.2f
 Vel@Top: %.2v 
"

const movement_settings_template: String = "
  SETTINGS
            player_speed: %.2f

           jump_velocity: %.2f

               air_decel: %.2f

        air_strafe_accel: %.2f

     player_gravity_mult: %.2f

        player_max_speed: %.2f
	 
  player_ground_friction: %.2f
"

func _ready() -> void:
	add_to_group("settings_dependent")
	Debug.msg_ready.connect(_on_log_message)
	Debug.toggle_debug_log.connect(_on_toggle_log)
	Debug.toggle_debug_movement.connect(_on_toggle_movement)
	$Log.visible = Debug.show_log
	$MovementInfo.visible = Debug.show_movement
	$MovementSettings.visible = Debug.show_movement
	$MovementSettings.text = movement_settings_template % [
		Settings.player_speed_value,
		Settings.jump_velocity_value,
		Settings.air_decel_value,
		Settings.air_strafe_accel_value,
		Settings.player_gravity_mult_value,
		Settings.player_max_speed_value,
		Settings.player_ground_friction_value
	]
	return
		
func _on_log_message(msg: String) -> void:
	$Log.text += msg + '\n'
	return
	
func _on_toggle_log(show_log: bool) -> void: 
	$Log.visible = show_log
	return
	
func _on_toggle_movement(show_movement: bool) -> void: 
	$MovementInfo.visible = show_movement
	$MovementSettings.visisble = show_movement
	return
	
func refresh_settings() -> void:
	$MovementSettings.text = movement_settings_template % [
		Settings.player_speed_value,
		Settings.jump_velocity_value,
		Settings.air_decel_value,
		Settings.air_strafe_accel_value,
		Settings.player_gravity_mult_value,
		Settings.player_max_speed_value,
		Settings.player_ground_friction_value
	]
	return
