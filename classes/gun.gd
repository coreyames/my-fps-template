class_name Gun extends Weapon

const default_ammo_scene: Resource = preload('res://scenes/entity/objects/proj.tscn')
var ammo_scene: Resource = default_ammo_scene
 
func attack(params) -> void:
	if typeof(params) == TYPE_VECTOR3:
		fire(params)

func fire(direction: Vector3) -> void:
	print('override me')
