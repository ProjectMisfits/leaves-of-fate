class_name Door extends Area2D
## A door that the player can interact with to move to a new room.

## Triggered when the player interacts with this Door.
signal player_entered_door(door: Door)

## The path of the Room to load when the player enters this Door.
@export_file("*_room.tscn") var path_to_target_room: String

## The name of this Door.
@export var door_name: String

## The name of the Door to spawn at in the target Room.
@export var target_door_name: String

## Emit the player_entered_door signal when the door is entered.
func _on_player_door_interact() -> void:
	# Should only emit signal when player presses correct control.
	player_entered_door.emit(self)
