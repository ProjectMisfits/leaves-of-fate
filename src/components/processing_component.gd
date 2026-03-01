class_name ProcessingComponent extends Node
## A component that enables or disables its parent based on event flag changes.

## An array containing the event flags that must be true for this trigger to be active.
@export var required_true_event_flags: Array[String]

## An array containing the event flags that must be false for this trigger to be active.
@export var required_false_event_flags: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _check_event_flags():
		_enable_entity()
	else:
		_disable_entity()

## Check whether the required event flags are satisfied.
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

## Enable the entity.
func _enable_entity() -> void:
	get_parent().show()
	get_parent().process_mode = Node.PROCESS_MODE_PAUSABLE

## Disable the entity.
func _disable_entity() -> void:
	get_parent().hide()
	get_parent().process_mode = Node.PROCESS_MODE_DISABLED
