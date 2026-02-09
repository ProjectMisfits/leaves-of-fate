class_name InteractComponent extends Node2D
## A component that manages player interaction.

## An array containing all interactables in the player's range.
var current_interactables: Array[InteractTrigger]

## A boolean representing whether the player can interact.
var can_interact: bool = true

## The interact prompt.
@onready var interact_prompt: Control = $InteractPrompt

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactables:
			can_interact = false
			current_interactables[0].trigger()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactables and can_interact:
		current_interactables.sort_custom(_sort_by_nearest)
		if current_interactables[0].enabled:
			interact_prompt.global_position = current_interactables[0].global_position
			interact_prompt.show()
	else:
		interact_prompt.hide()

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
	current_interactables.erase(area)
