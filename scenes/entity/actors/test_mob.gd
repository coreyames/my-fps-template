extends Mob

func _ready() -> void:
	super._ready()
	player_node = CharacterBody3D.new()
	player_location = world.get_node("SM_LittleHouse").global_position
	return

"""
func _physics_process(delta: float) -> void:		
	setup_behavior(maintain_pc_los, player_location, follow_player)
	simple_velocity(delta)
	if move_and_slide():
		handle_collisions()
	return
"""
