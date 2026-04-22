extends Node

signal projectile_hit(proj_id: int, collided_with_id: int)
signal apply_effects(target_id: int, effects: Array[Effect])
