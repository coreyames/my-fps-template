extends Control

# TODO placeholder for hit connection testing, will get from character later
const START_HP: int = 3
var remaining: int = START_HP
var loaded: int
var reserve: int
var equipped: Equippable

func _ready() -> void:
	$Status/HP.text = str(remaining) + ' HITS REMAINING' 
	get_parent().connect('was_hit', _on_was_hit)
	
	equipped = get_parent().equipped
	if equipped != null:
		equipped.connect('used', _on_equipped_used)
		if equipped.max_loaded != null && equipped.max_reserve != null:
			loaded = equipped.max_loaded
			reserve = equipped.max_reserve
			update_ammo_count(loaded, reserve)
	return

func _on_was_hit() -> void:
	remaining -= 1
	$Status/HP.text = '' + str(remaining) + ' HITS REMAINING' 
	return
							
func _on_equipped_used():
	update_ammo_count(loaded-1,reserve)
	return					

func update_ammo_count(_loaded: int, _reserve: int):
	# 'infinite ammo' effective for now
	loaded = _loaded
	if loaded == 0:
		loaded = equipped.max_loaded
	reserve = _reserve
	$EquippedInfo/Ammo.text = str(loaded) + ' / ' + str(reserve)
	return
