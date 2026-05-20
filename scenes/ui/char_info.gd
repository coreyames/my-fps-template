extends AspectRatioContainer

var player_name: String
var hp: int

const LABEL_TEXT_FORMAT: String = "
	%s
		HP: %d 
"
	
var label_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name = get_parent().player_name
	hp = get_parent().max_hp
	label_text = LABEL_TEXT_FORMAT % [player_name, hp]
	$VBoxContainer/TopRow/BasicInfoPanel/Label.text = label_text
	return
