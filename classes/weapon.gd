class_name Weapon extends Equippable

var max_loaded: int
var max_reserve: int
var sound_clip: AudioStreamMP3

func use(params) -> void:
	attack(params)
	return	

func attack(params) -> void:
	print('override me')
	return
