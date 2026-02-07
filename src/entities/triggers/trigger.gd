class_name Trigger extends Area2D
## An Area2D that can trigger game events based on player actions.

## The name of the Area2D to monitor for the presence of.
@export var trigger_name: String = ""

## Whether the trigger is enabled.
@export var enabled: bool = true

var trigger: Callable = func() -> void:
	pass

# interact trigger
# > dialogue trigger
# > event trigger (heater)

# grab trigger

# player overlap trigger
# > cutscene trigger
# > camera trigger, event trigger, etc.

# can trigger:
# dialogue sequence
# update event flag
# change entity grab state
