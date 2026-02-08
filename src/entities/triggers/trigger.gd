@abstract class_name Trigger extends Area2D
## Abstract base class for triggers.

## Whether the trigger is enabled.
@export var enabled: bool = true

## Whether the trigger can be activated more than once.
@export var repeatable: bool = false

## An array containing the event flags that must be true for this trigger to be active.
@export var required_event_flags: Array[String]

## Check that the trigger is active. If so, activate it.
func trigger() -> void:
	if _can_trigger():
		# Only disable the trigger if it only triggers once.
		if not repeatable:
			enabled = false
		_on_trigger.call()

## Returns whether the trigger can activate.
func _can_trigger() -> bool:
	# If any of the required event flags are false, this trigger isn't active, so return false.
	for flag: String in required_event_flags:
		if not EventFlags.get_flag(flag):
			return false
	# If all of them are true, return the trigger's enabled state.
	return enabled

## A Callable containing the logic to execute when the trigger is activated.
## Must be overridden in each trigger class to provide unique trigger functionality.
var _on_trigger: Callable = func() -> void:
	pass
