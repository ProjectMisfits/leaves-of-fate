class_name Door extends Node2D
## A door that the player can interact with to move to a new room.

## Triggered when the player interacts with this Door.
signal player_entered_door(door: Door)

## The path of the Room to load when the player enters this Door.
@export_file("*_room.tscn") var target_room_path: String

## The name of this Door.
@export var door_name: String

## The name of the Door to spawn at in the target room.
@export var target_door_name: String

## Emit the player_entered_door signal when the door trigger is activated.
func _on_door_trigger_activated() -> void:
	player_entered_door.emit(self)
