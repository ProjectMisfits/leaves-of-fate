class_name Gameplay extends Node2D
## Wrapper for gameplay scenes during runtime.

## A Node2D that acts as a persistent parent of the Room the player is in.
@onready var room_holder: Node2D = $RoomHolder

## The Room the player is currently in.
var current_room: Room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the current Room to the initial child of RoomHolder.
	current_room = room_holder.get_child(0) as Room
