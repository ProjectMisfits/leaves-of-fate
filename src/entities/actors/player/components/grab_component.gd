class_name GrabComponent extends Node2D
## A component that manages player grabbing.

## An array containing all grabbables in the player's range.
var current_grabbables: Array

## A boolean representing whether the player can grab.
var can_grab: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab") and can_grab:
		if current_grabbables:
			can_grab = false
			current_grabbables[0].hide_highlight()
			await current_grabbables[0].interact.call()
			can_grab = true

func _process(_delta: float) -> void:
	if current_grabbables and can_grab:
		current_grabbables.sort_custom(_sort_by_nearest)
		if current_grabbables[0].enabled:
			current_grabbables[0].show_highlight()

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
