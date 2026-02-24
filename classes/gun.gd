class_name Gun extends Weapon

const DEFAULT_AMMO_SCENE: Resource = preload('res://scenes/entity/objects/proj.tscn')
var ammo_scene: Resource = DEFAULT_AMMO_SCENE

const DEFAULT_SHOOT_SOUND: AudioStreamMP3 = preload('res://audio/meaty_gunshot.mp3')
const DEFAULT_MAX_LOADED: int = 30
const DEFAULT_MAX_RESERVE: int = 90

func _ready() -> void:
	max_loaded = DEFAULT_MAX_LOADED
	max_reserve = DEFAULT_MAX_RESERVE
	sound_clip = DEFAULT_SHOOT_SOUND

func attack(params) -> void:
	if typeof(params) == TYPE_VECTOR3:
		shoot(params)

func shoot(direction: Vector3) -> void:
	print('override me')
