extends Node

# global access as Settings

const PLAYER_SPEED_DEFAULT: float = 5.0
const JUMP_VELOCITY_DEFAULT: float = 4.5
const AIR_DECEL_DEFAULT_DENOM: float = PLAYER_SPEED_DEFAULT*PLAYER_SPEED_DEFAULT*100
const AIR_DECEL_DEFAULT: float = 1.0/(AIR_DECEL_DEFAULT_DENOM)
const AIR_STRAFE_ACCEL_DEFAULT: float = 0.25
const MOUSE_SENSITITY_DEFAULT: float = 50
const PLAYER_GRAVITY_MULT_DEFAULT: float = 1.0
const PLAYER_MAX_SPEED_DEFAULT: float = 100
const PLAYER_GROUND_FRICTION_DEFAULT: float = 0.1

var player_speed_value: float = PLAYER_SPEED_DEFAULT
var jump_velocity_value: float = JUMP_VELOCITY_DEFAULT
var air_decel_value: float = AIR_DECEL_DEFAULT
var air_strafe_accel_value: float = AIR_STRAFE_ACCEL_DEFAULT
var mouse_sensitivity_value: float = MOUSE_SENSITITY_DEFAULT
var player_gravity_mult_value: float = PLAYER_GRAVITY_MULT_DEFAULT
var player_max_speed_value: float = PLAYER_MAX_SPEED_DEFAULT
var player_ground_friction_value: float = PLAYER_GROUND_FRICTION_DEFAULT