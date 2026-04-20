extends ItemList

@onready var mouse_slider: HSlider = $MouseSlider
@onready var mouse_value: Label = $MousePanel/MouseValue

func _ready() -> void:
	mouse_value.text = str(Settings.mouse_sensitivity_value)
	mouse_slider.value = Settings.mouse_sensitivity_value
	
	mouse_slider.connect("value_changed", _on_mouse_slider_value_changed)
	mouse_slider.connect("drag_ended", _on_mouse_slider_drag_ended)
	$QuitButton.connect("pressed", _on_quit_button_pressed)
	return

func _on_mouse_slider_value_changed(value: float) -> void:
	mouse_value.text = str(value)
	return

func _on_mouse_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.mouse_sensitivity_value = mouse_slider.value;
		get_tree().call_group("settings_dependent", "refresh_settings")
	return

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	return
