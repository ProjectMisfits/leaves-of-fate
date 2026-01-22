class_name Gameplay extends Node2D
## Wrapper for gameplay scenes during runtime.
## Manages scenes like the current Room, HUD, and menus.

## A Node2D that acts as a persistent parent of the Room the player is in.
@onready var room_holder: Node2D = $RoomHolder

## The Room the player is currently in.
var current_room: Room = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the current Room to the initial child of RoomHolder.
	_update_current_room()

## Update the reference to the current scene.
func _update_current_room() -> void:
	# Get the last child of RoomHolder, as that will always be the current room.
	# TODO: find a more elegant solution; for some reason this line fires before the previous room gets queue_free()'d, so it wouldn't actually update.
	current_room = room_holder.get_child(-1) as Room
	# Because the room was replaced, we have to update the connected signal.
	# However, we have to make sure the connection doesn't already exist.
	if not current_room.swap_room.is_connected(_on_swap_room):
		current_room.swap_room.connect(_on_swap_room)

## Swap to the specified Room and unload the current Room.
func _on_swap_room(path_to_target_room: String, target_door_name: String)-> void:
	# Call autoload SceneManager to swap the room.
	SceneManager.swap_scenes(path_to_target_room, $RoomHolder, current_room)
	
	# Update the current room.
	_update_current_room()
	# Spawn the player at the target door now that the room has been loaded.
	current_room.spawn_player(target_door_name)
