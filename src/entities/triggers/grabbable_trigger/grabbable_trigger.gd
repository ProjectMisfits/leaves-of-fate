class_name GrabbableTrigger extends Area2D
## An Area2D that can be used to trigger Player grabs.

## The name of the player's grab area Area2D node.
var _grab_area_name: String = "GrabArea"

## Whether this trigger is grabbed or not.
var grabbed: bool = false

## Whether the player is overlapping the trigger.
var player_on_trigger: bool = false

func _physics_process(_delta: float) -> void:
	# Check if the player presses the interact button while on the trigger
	if player_on_trigger and Input.is_action_just_pressed("companion"):
		_trigger_grab()

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
	# Return early if the trigger is disabled for any reason.
	if not player_on_trigger:
		return
	
	grabbed = true
	
	## TODO: Do grabbed thing
