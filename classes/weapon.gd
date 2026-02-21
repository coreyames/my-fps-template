class_name Weapon extends Equippable

var max_loaded: int
var max_reserve: int

func use(params) -> void:
	attack(params)
	return	

func attack(params) -> void:
	print('override me')
	return
