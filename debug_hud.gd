extends TextEdit

func _ready() -> void:
	if Debug.is_on:
		Debug.connect("msg_ready", log_message);
		pass

func log_message(msg: String) -> void:
	text += msg + '\n';
	return;
