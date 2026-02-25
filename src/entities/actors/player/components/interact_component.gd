class_name InteractComponent extends Node2D
## A component that manages player interaction.

## An array containing all interactables in the player's range.
var current_interactables: Array[InteractTrigger]

## The currently highlighted interactable.
var highlighted_interactable: InteractTrigger = null

## A boolean representing whether the player can interact.
var can_interact: bool = true

func _ready() -> void:
	# Connect dialogue to interact
	DialogueManager.dialogue_started.connect(_disable_interact.unbind(1))
	DialogueManager.dialogue_ended.connect(_enable_interact.unbind(1))
	
	# Connect cutscenes to interact
	CutsceneManager.cutscene_started.connect(_disable_interact)
	CutsceneManager.cutscene_ended.connect(_enable_interact)

func _input(event: InputEvent) -> void:
	# When the interact input is pressed:
	if event.is_action_pressed("interact") and can_interact:
		# If there is something to interact with, interact with it.
		if highlighted_interactable:
			can_interact = false
			highlighted_interactable.trigger()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactables and can_interact:
		current_interactables.sort_custom(_sort_by_nearest)
		# Get the closest enabled interactable.
		for interactable: InteractTrigger in current_interactables:
			if interactable.enabled:
				highlighted_interactable = interactable
				break
		
		# Hide the prompt of any other interactables.
		for interactable: InteractTrigger in current_interactables:
			if interactable != highlighted_interactable:
				interactable.interact_prompt.hide()
		
		# Show the prompt of the closest enabled interactable.
		highlighted_interactable.interact_prompt.show()
	else:
		# Otherwise hide all interact prompts.
		if highlighted_interactable != null:
			highlighted_interactable.interact_prompt.hide()
			highlighted_interactable = null

## Return a boolean representing whether an area is closer to this area than another area.
func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area1_dist: float = global_position.distance_to(area1.global_position)
	var area2_dist: float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

## Add the area that entered the interact range to the current interactables array.
func _on_interact_range_area_entered(area: Area2D) -> void:
	if area is InteractTrigger:
		current_interactables.push_back(area)

## Remove the area that exited the interact range from the current interactables array.
func _on_interact_range_area_exited(area: Area2D) -> void:
	if area is InteractTrigger:
		area.interact_prompt.hide()
		current_interactables.erase(area)

## Disable interacting.
func _disable_interact() -> void:
	can_interact = false

## Enable interacting.
func _enable_interact() -> void:
	can_interact = true
