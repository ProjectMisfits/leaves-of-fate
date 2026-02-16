class_name CheckpointTrigger extends PlayerEnterTrigger
## A trigger for updating the player's reset checkpoint. Activates on player entry.

func _ready() -> void:
	_on_trigger = _update_checkpoint

## Update the player's checkpoint position.
func _update_checkpoint() -> void:
	pass
