extends Node2D


func _ready() -> void:
	$Star.visible = false
	EventFlags.flag_updated.connect(_on_event_flag_updated)

## Triggered when an event flag is updated. If the flag indicates that a heater should change state, change the state of this heater to match.
func _on_event_flag_updated(flag_name: String, flag_value: bool) -> void:
	if flag_name == "inhaler_available" and flag_value:
		$Star.visible = true
	
	if flag_name == "inhaler_retrieved" and flag_value:
		queue_free()
