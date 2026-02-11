class_name GrabTrigger extends Trigger
## A trigger for grabbable entities. Activates on player grab input.

## Whether this grab trigger is currently grabbed.
var is_grabbed: bool = false

## A reference to the grab highlight.
@onready var grab_highlight: Control

func _ready() -> void:
	grab_highlight = $GrabHighlight
	_on_trigger = _on_grab

## Grab the entity that this trigger is a child of.
func _on_grab() -> void:
	# If the parent has the grab handling functions,
	# Show the grab highlight
	# Call the grab handling functions
	if get_parent().has_method("_ungrab") and is_grabbed:
		get_parent()._ungrab()
		is_grabbed = false
	elif get_parent().has_method("_grab") and not is_grabbed:
		get_parent()._grab()
		is_grabbed = true
	else:
		push_error("GrabTrigger: Parent node does not have appropriate _grab and/or _ungrab methods")
