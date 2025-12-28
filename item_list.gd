extends ItemList

@export var mouse_slider: HSlider
@export var mouse_value: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_value.text = str(Settings.mouse_sensitivity);
	mouse_slider.value = Settings.mouse_sensitivity; 

#TODO replace with in code signal connections
func _on_mouse_slider_value_changed(value: float) -> void:
	mouse_value.text = str(value);

func _on_mouse_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.mouse_sensitivity = mouse_slider.value;
		get_tree().call_group("settings_dependent", "refresh_settings");

func _on_quit_button_pressed() -> void:
	get_tree().quit();
