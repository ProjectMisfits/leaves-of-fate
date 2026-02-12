class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## Triggered when the player interacts with a door to transition to a new room.
signal swap_room(path_to_target_room: String, spawn_location: String)
## Triggered when the player is knocked out to reset the current room.
signal reset_room(respawn_location: String)

## The Player scene.
@onready var player: Player = %Player
## A holder node for all doors in this Room.
@onready var door_holder: Node2D = %DoorHolder
## A tilemaplayer defining collision surfaces for this room.
@onready var midground: TileMapLayer = %Midground

## An array containing all Doors in this Room that lead to other Rooms.
var doors: Array[Node]
## The name of the Door the player entered the room from.
var last_entered_door: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect each Door's entered signal to this Room's room swap function
	doors = door_holder.get_children()
	for door: Door in doors:
		door.player_entered_door.connect(_on_player_entered_door)
	
	# TODO: fix to set up gameplay and teleport to the room instead
	# If the room is being run standalone, we have to make sure the player gets instantiated.
	if get_tree().current_scene == self:
		# IDK yet
		pass

## Initiate room swap on player entering a Door.
func _on_player_entered_door(door: Door) -> void:
	# Check whether the door has a destination first.
	if (door.path_to_target_room == ""):
		push_warning("Room '%s': Door '%s' does not have a target room set!" % [name, door.door_name])
		return
	# Since the path to the target room is set, emit room load signal
	swap_room.emit(door.path_to_target_room, door.target_door_name)

## Emit a signal to reset the room when the player gets knocked out.
func _on_player_player_knocked_out() -> void:
	reset_room.emit()

## Spawn the player at the given door.
func spawn_player_at_door(target_door_name: String) -> void:
	# If a door with the given name exists, put the player there.
	for door: Door in doors:
		if door.door_name == target_door_name:
			player.global_position = door.global_position
			last_entered_door = target_door_name
			return
	# If the target door didn't exist anywhere in the room, report the issue
	push_warning("Room '%s': Door '%s' does not exist in this room" % [name, target_door_name])
