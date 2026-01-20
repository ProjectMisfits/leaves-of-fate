class_name Door extends Area2D
## A door that the player can interact with to move to a new room.

## Signifies when a player has interacted with a door.
signal player_entered_door(door: Door)

## The scene to load when the player enters the door.
@export var path_to_new_scene: String

## The name of the door to enter through in the loaded scene.
@export var entry_door_name: String

## Emit the player_entered_door signal when the door is entered.
func _on_player_entered_door() -> void:
	print("door interacted with. emitting room_changed signal")
	player_entered_door.emit(self)
