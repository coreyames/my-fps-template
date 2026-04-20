extends Node

# global access as Settings

enum Setting {
	MOUSE,
	PLAYER_SPEED,
	AIR_STRAFE_ACCEL,
	AIR_DECEL
}

const PLAYER_SPEED_DEFAULT: float = 5.0
var player_speed_value: float = PLAYER_SPEED_DEFAULT

const JUMP_VELOCITY_DEFAULT: float = 4.5
const jump_velocity_value: float = JUMP_VELOCITY_DEFAULT

const AIR_DECEL_DEFAULT: float = 1.0/(PLAYER_SPEED_DEFAULT*PLAYER_SPEED_DEFAULT*100) # idfk lol
var air_decel_value: float = AIR_DECEL_DEFAULT

const AIR_STRAFE_ACCEL_DEFAULT: float = 0.5
var air_strafe_accel_value: float = AIR_STRAFE_ACCEL_DEFAULT

const MOUSE_SENSITITY_DEFAULT: float = 50
var mouse_sensitivity_value: float = MOUSE_SENSITITY_DEFAULT
