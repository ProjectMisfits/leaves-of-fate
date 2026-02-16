class_name CheckpointTrigger extends PlayerEnterTrigger
## A trigger for updating the player's reset checkpoint. Activates on player entry.

## The Marker2D indicating this checkpoint trigger's respawn location.
@export var location: Marker2D

func _ready() -> void:
	_on_trigger = _update_checkpoint

## Update the player's checkpoint location.
func _update_checkpoint() -> void:
	if location == null:
		push_warning("CheckpointTrigger: No marker location set!")
		return
	SceneManager.current_scene.player_spawn_location = location.global_position
