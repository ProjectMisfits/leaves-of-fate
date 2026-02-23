class_name ObjectTrigger extends InteractTrigger
## A trigger that updates an event flag. Activates on player interact input.

## The name of the flag to update.
@export var flag_name: String
## The value to change the flag to.
@export var new_flag_value: bool

func _ready() -> void:
	interact_prompt = $InteractPrompt
	_on_trigger = _on_object_interact

## Change an event flag when this trigger is interacted with.
func _on_object_interact() -> void:
	# Make sure an event flag for this object is set
	if flag_name == null:
		push_error("ObjectTrigger: No event flag set")
		return
	# Update the event flag
	EventFlags.set_flag(flag_name, new_flag_value)
