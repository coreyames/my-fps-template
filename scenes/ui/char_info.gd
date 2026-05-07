extends AspectRatioContainer

var player_name: String
var hp: int
var sp: int
var pr: int
var mr: int

const LABEL_TEXT_FORMAT: String = "
	%s
		HP: %d 
		SP: %d
		PR: %d
		MR:	%d
"
	
var label_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_name = get_parent().player_name
	hp = get_parent().max_health
	sp = get_parent().max_resource
	pr = get_parent().phys_reduction
	mr = get_parent().magic_reduction
	label_text = LABEL_TEXT_FORMAT % [player_name, hp, sp, pr, mr]
	$VBoxContainer/TopRow/BasicInfoPanel/Label.text = label_text
	return
