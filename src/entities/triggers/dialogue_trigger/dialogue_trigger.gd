class_name DialogueTrigger extends Area2D
## An Area2D that can be used to trigger dialogue sequences.

## The dialogue sequence that this dialogue trigger will initiate.
@export var dialogue_sequence: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

## Whether this trigger requires player interaction to begin.
@export var requires_interact: bool = false

## The name of the player's interact area Area2D node.
var interact_area_name: String = "InteractArea"

## The dialogue balloon that this dialogue trigger should use.
var dialogue_balloon: PackedScene = preload("res://src/ui/dialogue_boxes/dialogue_box.tscn")

## Whether this dialogue trigger is enabled.
var dialogue_enabled: bool = true

## Whether the player is overlapping the trigger.
var player_on_trigger: bool = false

## This trigger's interact prompt scene. Only set and used if this trigger has requires_interact set to true.
var interact_prompt: Control = null

func _ready() -> void:
	# if this trigger is interactable, load an interact prompt as a child and position it above the interact area.
	if requires_interact:
		interact_prompt = load("res://src/ui/interact_prompt/interact_prompt.tscn").instantiate()
		var trigger_shape: Shape2D = $CollisionShape2D.shape
		var shape_size: Rect2 = trigger_shape.get_rect()
		# Offset the prompt to be above the trigger's top edge.
		interact_prompt.position.y -= shape_size.size.y / 2 + 32
		interact_prompt.hide()
		add_child(interact_prompt)

func _physics_process(_delta: float) -> void:
	# Check if the player presses the interact button while on the trigger
	if player_on_trigger and Input.is_action_just_pressed("interact"):
		_trigger_dialogue()

# Triggered when an area enters this trigger's area.
func _on_area_entered(area: Node2D) -> void:
	if area.name == interact_area_name:
		if requires_interact:
			player_on_trigger = true
			interact_prompt.show()
			# Kind of hacky, but needed to prevent automatic dialogue triggers
			# from needing to load an interact prompt child that they'll never use.
			# This is to just get it working; later the plan is to create an abstract trigger
			# and split dialogue and interact triggers into their own classes.
			interact_prompt.get_node("AnimationPlayer").play(&"bobbing")
		else:
			_trigger_dialogue()

# Triggered when an area exits this trigger's area.
func _on_area_exited(area: Node2D) -> void:
	if area.name == interact_area_name:
		if requires_interact:
			player_on_trigger = false
			interact_prompt.hide()
			interact_prompt.get_node("AnimationPlayer").stop()

## Initiate the set dialogue sequence when the player overlaps the trigger.
func _trigger_dialogue() -> void:
	# Return early if the trigger is disabled for any reason.
	if not _can_dialogue_trigger():
		return
	
	# Prevent this trigger from being activated again
	dialogue_enabled = false
	# start the dialogue sequence
	DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_sequence, dialogue_start)

## Check whether this dialogue trigger is active. If so, return true. Otherwise return false.
func _can_dialogue_trigger() -> bool:
	if not dialogue_enabled:
		return false
	# TODO: implement event flag checking
	return true
