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

@onready var grab_timer: Timer = $GrabTimer	## Reference to the Grab Timer.
var _max_grab_time: float = 1.0				## How long (in seconds) a grab may be sustained before being automatically released.

func _ready() -> void:
	# Connect dialogue to grab
	DialogueManager.dialogue_started.connect(_disable_grab.unbind(1))
	DialogueManager.dialogue_ended.connect(_enable_grab.unbind(1))
	
	# Connect cutscenes to grab
	CutsceneManager.cutscene_started.connect(_disable_grab)
	CutsceneManager.cutscene_ended.connect(_enable_grab)

func _process(_delta: float) -> void:
	# Handle inputs.
	if Input.is_action_just_pressed("grab"):
		if highlighted_grabbable and can_grab:	# If something can be grabbed, grab it.
			_initiate_grab()
	elif current_grab and Input.is_action_just_released("grab"):	# If something is grabbed, release it.
		_release_grab()
	
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
				grabbable.set_highlight_visibility(false)
		
		# Show the highlight of the closest enabled grabbable.
		if highlighted_grabbable:
			highlighted_grabbable.grab_highlight.show()
			highlighted_grabbable.set_highlight_visibility(true)

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
		area.set_highlight_visibility(false)
		current_grabbables.erase(area)

## Disable grabbing on dialogue start.
func _disable_grab() -> void:
	can_grab = false

## Enable grabbing on dialogue end.
func _enable_grab() -> void:
	can_grab = true

## Setter for _max_grab_time.
func set_max_grab_time(new_grab_time: float) -> void:
	if (new_grab_time >= 0.0):
		_max_grab_time = new_grab_time
	else:
		push_warning("GrabComponent set_max_grab_time(): Negative value given.")

## Grab the currently highlighted object.
func _initiate_grab() -> void:
	if highlighted_grabbable and can_grab:
		current_grab = highlighted_grabbable
		current_grab.trigger()
		EventBus.grabbed.emit()
		highlighted_grabbable.grab_highlight.hide()
		highlighted_grabbable.set_highlight_visibility(false)
		highlighted_grabbable = null
		
		grab_timer.start(_max_grab_time)
	else:
		push_warning("GrabComponent _initiate_grab(): Function called with \
		either no highlighted grabbable OR while not allowed to grab.")

## Release the currently grabbed object.
## Note: also connected to GrabTimer Timeout signal.
func _release_grab() -> void:
	EventBus.ungrabbed.emit()
	current_grab.trigger()
	current_grab = null
	grab_timer.stop()	# Stop timer if grab release was done manually.
