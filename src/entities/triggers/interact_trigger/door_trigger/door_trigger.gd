class_name DoorTrigger extends InteractTrigger
## A trigger for doors. Activated on player interact input.

## Triggered when the player interacts with this trigger.
signal door_trigger_activated

func _ready() -> void:
	interact_prompt = $InteractPrompt
	_on_trigger = _enter_door

## Initiate the room transition this door represents.
func _enter_door() -> void:
	door_trigger_activated.emit()
