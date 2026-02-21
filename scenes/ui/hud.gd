extends Control

var remaining: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Status/HP.text = str(remaining) + ' HITS REMAINING' 
	var equipped: Equippable = get_parent().equipped
	if equipped.max_loaded != null && equipped.max_reserve != null:
		$EquippedInfo/Ammo.text = str(equipped.max_loaded) + ' / ' + str(equipped.max_reserve)
	get_parent().connect('was_hit', _on_was_hit)
	return

func _on_was_hit() -> void:
	remaining -= 1
	$Status/HP.text = '' + str(remaining) + ' HITS REMAINING' 
	return
												
