class_name CutsceneTrigger extends Area2D

## The dialogue sequence that this cutscene trigger will initiate.
@export var dialogue_sequence: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

## The dialogue balloon that this cutscene trigger should use.
var dialogue_balloon: PackedScene = preload("res://src/ui/dialogue_boxes/dialogue_box.tscn")

## Whether this cutscene trigger is enabled.
var cutscene_enabled: bool = true

# Triggered when a body enters the area.
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_trigger_cutscene()

## Initiate the set dialogue sequence when the player overlaps the trigger.
func _trigger_cutscene() -> void:
	if not _can_cutscene_trigger():
		return
	
	# Prevent this trigger from activating a cutscene again.
	cutscene_enabled = false
	# Enable cutscene state
	
	# start the dialogue sequence
	DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_sequence, dialogue_start)

## Check whether this cutscene trigger is active. If so, return true. Otherwise return false.
func _can_cutscene_trigger() -> bool:
	if not cutscene_enabled:
		return false
	
	# Check that game state is as expected
	#if EventFlags.get_flag() num heaters enabled
	return true
