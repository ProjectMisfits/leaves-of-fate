class_name EventTrigger extends PlayerEnterTrigger
## A trigger for updating event flags. Activates on player entry.

## The name of the event flag to update.
@export var flag_name: String = ""

## The new value to set the event flag to.
@export var new_value: bool = false

func _ready() -> void:
	init_trigger()
	_on_trigger = _update_flag

## Update the event flag with the new value.
func _update_flag() -> void:
	EventFlags.set_flag(flag_name, new_value)
