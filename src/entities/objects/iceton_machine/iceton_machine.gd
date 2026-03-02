class_name IcetonMachine extends Decor

func _ready() -> void:
	super()
	EventFlags.flag_updated.connect(_on_event_flag_updated)

## Triggered when an event flag is updated. If Iceton was released, update the machine visual to match.
func _on_event_flag_updated(flag_name: String, flag_value: bool) -> void:
	if flag_name == "iceton_released" and flag_value:
		%CloneMachineOpen.visible = true
