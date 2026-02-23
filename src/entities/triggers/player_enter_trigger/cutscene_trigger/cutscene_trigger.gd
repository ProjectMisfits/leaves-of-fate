class_name CutsceneTrigger extends PlayerEnterTrigger
## A trigger for cutscenes. Activates on player entry.

## The dialogue sequence that this cutscene trigger will initiate.
@export var dialogue_sequence: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

## Whether the cutscene associated with this trigger is currently playing out.
var cutscene_active: bool = false

func _ready() -> void:
	_on_trigger = _start_cutscene
	DialogueManager.dialogue_ended.connect(_end_cutscene.unbind(1))

## Start the cutscene associated with this trigger.
func _start_cutscene() -> void:
	cutscene_active = true
	CutsceneManager.cutscene_started.emit()
	DialogueManager.show_dialogue_balloon(dialogue_sequence, dialogue_start)

## End the cutscene associated with this trigger.
func _end_cutscene() -> void:
	# If this cutscene was active when the dialogue manager signaled that dialogue ended, emit the cutscene ended signal
	if cutscene_active:
		cutscene_active = false
		CutsceneManager.cutscene_ended.emit()
