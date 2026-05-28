class_name Weapon extends Equippable

var max_loaded: int
var max_reserve: int
var sound_clip: AudioStreamMP3

@warning_ignore_start("untyped_declaration")
func use(params) -> void:
	attack(params)
	return	


func attack(params) -> void:
	print('override me')
	return
