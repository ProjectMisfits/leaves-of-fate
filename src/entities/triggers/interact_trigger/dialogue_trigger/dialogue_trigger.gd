class_name DialogueTrigger extends InteractTrigger
## A trigger for dialogue sequences. Activates on player interact input.

## The dialogue sequence that this dialogue trigger will initiate.
@export var dialogue_sequence: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

## The name of the event flag to update when this trigger is activated. Updating the event flag is optional.
@export var flag_name: String

## The value to change the event flag to.
@export var new_flag_value: bool

## Plays the interact sound when a trigger is interacted with.
@onready var interact_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	interact_prompt = $InteractPrompt
	_on_trigger = _start_dialogue

## Start the dialogue sequence associated with this trigger.
func _start_dialogue() -> void:
	if not dialogue_sequence:
		push_warning("DialogueTrigger: Trigger has no dialogue sequence set.")
		return
	
	if not dialogue_sequence.get_titles().has(dialogue_start):
		push_warning("DialogueTrigger: Trigger dialogue sequence does not have the specified dialogue start.")
		return
	
	interact_audio.play()
	DialogueManager.show_dialogue_balloon(dialogue_sequence, dialogue_start)
	
	# If an event flag has been set for this trigger, update it.
	if flag_name != null:
		EventFlags.set_flag(flag_name, new_flag_value)
