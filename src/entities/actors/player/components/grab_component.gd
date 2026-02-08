class_name GrabComponent extends Node2D
## A component that manages player grabbing.

## An array containing all grabbables in the player's range.
var current_grabbables: Array[GrabTrigger]

## A boolean representing whether the player can grab.
var can_grab: bool = true

## The currently grabbed entity. Kept so that it can be ungrabbed.
var current_grab: GrabTrigger = null

## The grab highlight indicator.
@onready var grab_highlight: Control = $InteractPrompt

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		# If something is currently grabbed, release it.
		if current_grab:
			current_grab.trigger()
			current_grab = null
			can_grab = true
		# If nothing is currently grabbed and there is something available to grab, grab it.
		elif not current_grab and current_grabbables:
			can_grab = false
			current_grab = current_grabbables[0]
			current_grab.trigger()

func _process(_delta: float) -> void:
	if current_grabbables and can_grab:
		current_grabbables.sort_custom(_sort_by_nearest)
		if current_grabbables[0].enabled:
			grab_highlight.global_position = current_grabbables[0].global_position
			grab_highlight.show()
	else:
		grab_highlight.hide()

## Return a boolean representing whether an area is closer to this area than another area.
func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area1_dist: float = global_position.distance_to(area1.global_position)
	var area2_dist: float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

## Add the area that entered the grab range to the current grabbables array.
func _on_grab_range_area_entered(area: Area2D) -> void:
	current_grabbables.push_back(area)

## Remove the area that left the grab range from the current grabbables array.
func _on_grab_range_area_exited(area: Area2D) -> void:
	current_grabbables.erase(area)
