@abstract class_name Trigger extends Area2D
## Abstract base class for triggers.

## Set to true to enable this trigger regardless of event flag status.
@export var force_disable: bool = false

## Whether the trigger is enabled.
var enabled: bool = false

## An array containing the event flags that must be true for this trigger to be active.
@export var required_true_event_flags: Array[String]

## An array containing the event flags that must be false for this trigger to be active.
@export var required_false_event_flags: Array[String]

## Set up the trigger.
func init_trigger() -> void:
	# Check event flags to set this trigger's enabled variable
	_update_enabled()
	# Update this trigger's enabled state whenever an event flag changes
	EventFlags.flag_updated.connect(_update_enabled.unbind(2))

## Update this trigger's enabled state.
func _update_enabled() -> void:
	enabled = _check_event_flags()

## Check whether this trigger's required event flags are satisfied.
func _check_event_flags() -> bool:
	# Check for any required true event flags being false
	for flag: String in required_true_event_flags:
		if EventFlags.get_flag(flag) == false:
			return false
	# Check for any required false event flags being true
	for flag: String in required_false_event_flags:
		if EventFlags.get_flag(flag) == true:
			return false
	# All required flags are satisfied
	return true

## Check that the trigger is active. If so, activate it.
func trigger() -> void:
	if _can_trigger():
		# Call the trigger method
		_on_trigger.call()

## Returns whether the trigger can activate.
func _can_trigger() -> bool:
	# Return true if the trigger is enabled according to event flags or enabled override
	return enabled and !force_disable

## A Callable containing the logic to execute when the trigger is activated.
## Must be overridden in each trigger class to provide unique trigger functionality.
var _on_trigger: Callable = func() -> void:
	pass
