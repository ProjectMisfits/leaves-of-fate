@abstract class_name Trigger extends Area2D
## Abstract base class for triggers.

## Whether the trigger is enabled.
@export var enabled: bool = true

## Whether the trigger can be activated more than once.
@export var repeatable: bool = false

## An array containing the event flags that must be true for this trigger to be active.
@export var required_true_event_flags: Array[String]

## An array containing the event flags that must be false for this trigger to be active.
@export var required_false_event_flags: Array[String]

## Check that the trigger is active. If so, activate it.
func trigger() -> void:
	if _can_trigger():
		# Disable the trigger if it only triggers once
		if not repeatable:
			enabled = false
		# Call the trigger method
		_on_trigger.call()

## Returns whether the trigger can activate.
func _can_trigger() -> bool:
	# If any of the required true event flags are false, this trigger should be disabled, so return false.
	for flag: String in required_true_event_flags:
		if not EventFlags.get_flag(flag) == false:
			enabled = false
	# If any of the required false event flags are true, this trigger should be disabled, so return false
	for flag: String in required_false_event_flags:
		if EventFlags.get_flag(flag) == true:
			enabled = false
	# Return this trigger's enabled state. If any of the above failed, this will be false.
	return enabled

## A Callable containing the logic to execute when the trigger is activated.
## Must be overridden in each trigger class to provide unique trigger functionality.
var _on_trigger: Callable = func() -> void:
	pass
