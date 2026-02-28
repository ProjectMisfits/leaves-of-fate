class_name GrabComponent extends Node2D
## A component that manages player grabbing.

## An array containing all grabbables in the player's range.
var current_grabbables: Array[GrabTrigger]

## The currently highlighted grabbable.
var highlighted_grabbable: GrabTrigger = null

## The currently grabbed entity. Kept so that it can be ungrabbed.
var current_grab: GrabTrigger = null

## A boolean representing whether the player can grab.
var can_grab: bool = true

func _ready() -> void:
	# Connect dialogue to grab
	DialogueManager.dialogue_started.connect(_disable_grab.unbind(1))
	DialogueManager.dialogue_ended.connect(_enable_grab.unbind(1))
	
	# Connect cutscenes to grab
	CutsceneManager.cutscene_started.connect(_disable_grab)
	CutsceneManager.cutscene_ended.connect(_enable_grab)

func _input(event: InputEvent) -> void:
	# When the grab input is pressed:
	if event.is_action_pressed("grab"):
		# If something is grabbed, release it.
		if current_grab:
			current_grab.trigger()
			current_grab = null
	
		# If something can be grabbed, grab it.
		if highlighted_grabbable and can_grab:
			current_grab = highlighted_grabbable
			current_grab.trigger()
			highlighted_grabbable.grab_highlight.hide()
			highlighted_grabbable = null

func _process(_delta: float) -> void:
	if current_grabbables and can_grab:
		current_grabbables.sort_custom(_sort_by_nearest)
		# Get the closest enabled grabbable.
		for grabbable: GrabTrigger in current_grabbables:
			if not grabbable.is_grabbed:
				highlighted_grabbable = grabbable
				break
		
		# Hide the highlight of any other grabbables.
		for grabbable: GrabTrigger in current_grabbables:
			if grabbable != highlighted_grabbable or grabbable.is_grabbed:
				grabbable.grab_highlight.hide()
		
		# Show the highlight of the closest enabled grabbable.
		if highlighted_grabbable:
			highlighted_grabbable.grab_highlight.show()

## Return a boolean representing whether an area is closer to this area than another area.
func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area1_dist: float = global_position.distance_to(area1.global_position)
	var area2_dist: float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

## Add the area that entered the grab range to the current grabbables array.
func _on_grab_range_area_entered(area: Area2D) -> void:
	if area is GrabTrigger:
		current_grabbables.push_back(area)

## Remove the area that left the grab range from the current grabbables array.
func _on_grab_range_area_exited(area: Area2D) -> void:
	if area is GrabTrigger:
		area.grab_highlight.hide()
		current_grabbables.erase(area)

## Disable grabbing on dialogue start.
func _disable_grab() -> void:
	can_grab = false

## Enable grabbing on dialogue end.
func _enable_grab() -> void:
	can_grab = true
