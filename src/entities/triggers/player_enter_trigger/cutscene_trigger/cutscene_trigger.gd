class_name CutsceneTrigger extends PlayerEnterTrigger
## A trigger for cutscenes. Activates on player entry.

## The dialogue sequence that this cutscene trigger will initiate.
@export var dialogue_sequence: DialogueResource

## The line to start at in the dialogue sequence.
@export var dialogue_start: String = "start"

func _ready() -> void:
	_on_trigger = _start_cutscene

## Start the cutscene associated with this trigger.
func _start_cutscene() -> void:
	CutsceneManager.cutscene_started.emit()
	DialogueManager.show_dialogue_balloon(dialogue_sequence, dialogue_start)
