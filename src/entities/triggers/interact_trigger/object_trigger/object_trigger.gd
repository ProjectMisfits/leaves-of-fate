class_name ObjectTrigger extends InteractTrigger
## A trigger for objects in the world. Activates on player interact input.

func _ready() -> void:
	_on_trigger = _change_object_state

## Change the object/world state as dictated by the object.
func _change_object_state() -> void:
	# For example, make heater levers turn on a heater.
	pass
