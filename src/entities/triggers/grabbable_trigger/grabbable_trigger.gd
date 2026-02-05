## An Area2D that can be used to trigger Player grabs.
## To make a scene "grabbable", nest a GrabbableTrigger as a direct child of
## the scene & add two functions to the scene's script:
## "grab()" and "release_grab()".
extends Area2D
class_name GrabbableTrigger

var _grab_area_name: String = "GrabArea"	## The name of the player's grab area Area2D node.
var grabbed: bool = false					## Whether this trigger is grabbed or not.
var player_on_trigger: bool = false			## Whether the player is overlapping the trigger.

func _physics_process(_delta: float) -> void:
	# Check if the player presses the interact button while on the trigger
	if Input.is_action_just_pressed("companion"):
		if player_on_trigger and (not grabbed):
			_trigger_grab()
		elif (grabbed):
			_release_grab()

## Triggered when an area enters this trigger's area.
func _on_area_entered(area: Node2D) -> void:
	if area.name == _grab_area_name:
		player_on_trigger = true

## Triggered when an area exits this trigger's area.
func _on_area_exited(area: Node2D) -> void:
	if area.name == _grab_area_name:
		player_on_trigger = false

## Initiate the grab when the player overlaps the trigger and presses the companion action.
func _trigger_grab() -> void:
		if not player_on_trigger:
			push_warning("_trigger_grab(): Player does not overlap with the Grabbable Trigger Area.")
			return
		elif grabbed:
			push_warning("_trigger_grab(): Grab has already been initiated.")
			return
		
		grabbed = true
		get_parent().grab()	# Delegate grab effects to parent.

## Release the current grab.
func _release_grab() -> void:
	if not grabbed:
		push_warning("_release_grab(): Grabbed was not initiated.")
		return
	
	grabbed = false
	get_parent().release_grab()	# Delegate grab effects to parent.
