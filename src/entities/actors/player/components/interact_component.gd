class_name InteractComponent extends Node2D
## A component that manages player interaction.

## An array containing all interactables in the player's range.
var current_interactables: Array[InteractTrigger]

## A boolean representing whether the player can interact.
var can_interact: bool = true

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started.unbind(1))
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended.unbind(1))

func _input(event: InputEvent) -> void:
	# When the interact input is pressed:
	if event.is_action_pressed("interact") and can_interact:
		# If there is something to interact with, interact with it.
		if current_interactables:
			can_interact = false
			current_interactables[0].interact_prompt.hide()
			current_interactables[0].trigger()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactables and can_interact:
		current_interactables.sort_custom(_sort_by_nearest)
		# Hide any visible prompts of interactables that aren't the closest one.
		if current_interactables[0].enabled:
			for interactable: InteractTrigger in current_interactables:
				if interactable != current_interactables[0] and interactable.interact_prompt.visible == true:
					interactable.interact_prompt.hide()
			# Make sure the closest interactables's prompt is visible.
			current_interactables[0].interact_prompt.show()

## Return a boolean representing whether an area is closer to this area than another area.
func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var area1_dist: float = global_position.distance_to(area1.global_position)
	var area2_dist: float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

## Add the area that entered the interact range to the current interactables array.
func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactables.push_back(area)

## Remove the area that exited the interact range from the current interactables array.
func _on_interact_range_area_exited(area: Area2D) -> void:
	if area is InteractTrigger:
		area.interact_prompt.hide()
	current_interactables.erase(area)

## Disable interacting on dialogue start.
func _on_dialogue_started() -> void:
	can_interact = false

## Enable interacting on dialogue end.
func _on_dialogue_ended() -> void:
	can_interact = true
