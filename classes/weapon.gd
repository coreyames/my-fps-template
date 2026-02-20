class_name Weapon extends Equippable

func use(params) -> void:
	attack(params)
	return	

func attack(params) -> void:
	print('override me')
	return
