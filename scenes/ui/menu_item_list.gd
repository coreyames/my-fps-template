extends ItemList

@onready var mouse_slider: HSlider = $MouseSlider
@onready var mouse_value: Label = $MousePanel/MouseValue
@onready var fov_slider: HSlider = $FovSlider
@onready var fov_value: Label = $FovPanel/FovValue

func _ready() -> void:
	mouse_value.text = str(Settings.mouse_sensitivity_value)
	mouse_slider.value = Settings.mouse_sensitivity_value
	fov_value.text = str(Settings.fov_value)
	fov_slider.value = Settings.fov_value
	
	mouse_slider.connect("value_changed", _on_mouse_slider_value_changed)
	mouse_slider.connect("drag_ended", _on_mouse_slider_drag_ended)
	fov_slider.connect("value_changed", _on_fov_slider_value_changed)
	fov_slider.connect("drag_ended", _on_fov_slider_drag_ended)
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

func _on_fov_slider_value_changed(value: float) -> void:
	fov_value.text = str(value)
	return

func _on_fov_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.fov_value = fov_slider.value;
		get_tree().call_group("settings_dependent", "refresh_settings")
	return

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	return

func get_ok_button() -> Button:
	return $OkButton
