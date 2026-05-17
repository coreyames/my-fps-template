extends Mob

func _ready() -> void:
	super._ready()
	var effect: Effect = Effect.new() 
	effect.type = Effect.Type.DAMAGE
	effect.min_dmg = 5
	effect.max_dmg = 10
	effects.append(effect)
	
	# try to sub house if player not present on current test map
	if !player_node:
		var house_node = world.get_node_or_null("SM_LittleHouse")
		if house_node:
			player_location = house_node.global_position
	return
