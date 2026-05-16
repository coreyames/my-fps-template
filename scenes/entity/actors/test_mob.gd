extends Mob

func _ready() -> void:
	super._ready()
	# try to fake up player node if not present on test map
	if !player_node:
		var house_node = world.get_node_or_null("SM_LittleHouse")
		if house_node:
			player_location = house_node.global_position
	return
