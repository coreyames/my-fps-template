extends Control

# TODO placeholder for hit connection testing, will get from character later
var hp: int
var loaded: int
var reserve: int
@onready var equipped: Equippable

func _ready() -> void:
	$Status/HP.text = str(get_parent().max_hp)
	hp = get_parent().max_hp
	get_parent().connect('was_hit', _on_was_hit)
	equipped = get_parent().equipped
	
	if equipped != null:
		equipped.connect('used', _on_equipped_used)
		if equipped.max_loaded != null && equipped.max_reserve != null:
			loaded = equipped.max_loaded
			reserve = equipped.max_reserve
			update_ammo_count(loaded, reserve)
	return

func _on_was_hit(effects: Array[Effect]) -> void: 
	for effect: Effect in effects:
		if effect.type == Effect.Type.DAMAGE:
			hp -= effect.dmg_dealt
			$Status/HP.text = str(hp)
	return
							
func _on_equipped_used():
	update_ammo_count(loaded-1,reserve)
	return					

func update_ammo_count(_loaded: int, _reserve: int):
	# 'infinite ammo + auto reaload' effective for now
	loaded = _loaded
	if loaded == 0:
		loaded = equipped.max_loaded
	reserve = _reserve
	$EquippedInfo/Ammo.text = str(loaded) + ' / ' + str(reserve)
	return
