extends Mob

func _ready() -> void:
	super._ready()
	# try to fake up player node if not present on test map
	if !player_node:
		player_node = world.get_node_or_null("SM_LittleHouse")
		if player_node:
			player_location = player_node.global_position
	return
