class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## Triggered when the player interacts with a door to transition to a new room.
signal swap_room(target_room_path: String, target_door_name: String)
## Triggered when the player is knocked out to reset the current room.
signal reset_room

## The Player scene.
@onready var player: Player = %Player
## A holder node for all doors in this Room.
@onready var door_holder: Node2D = %DoorHolder
## A tilemaplayer defining collision surfaces for this room.
@onready var midground: TileMapLayer = %Midground

## An array containing all Doors in this Room that lead to other Rooms.
var doors: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect each door signal to the enter door method
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
	# Check whether the door has a destination
	if door.target_room_path == "":
		push_warning("Room '%s': Door '%s' does not have a target room set" % [name, door.door_name])
		return
	# Disable player processing so they don't move during the transition
	player.process_mode = Node.PROCESS_MODE_DISABLED
	swap_room.emit(door.target_room_path, door.target_door_name)

## Emit a signal to reset the room when the player gets knocked out.
func _on_player_player_knocked_out() -> void:
	# Disable player processing so signal is only emitted once
	player.process_mode = Node.PROCESS_MODE_DISABLED
	reset_room.emit()

## Spawn the player at the given door.
func spawn_player_at_door(target_door_name: String) -> Vector2:
	for door: Door in doors:
		if door.door_name == target_door_name:
			# If a door with the given name exists:
			set_player_location(door.global_position)
			# Enable player processing
			player.process_mode = Node.PROCESS_MODE_INHERIT
			return door.global_position
	# If the target door didn't exist anywhere in the room, report the issue
	push_warning("Room '%s': Door '%s' does not exist in this room" % [name, target_door_name])
	return Vector2(0, 0)

## Set the player's location.
func set_player_location(new_location: Vector2) -> void:
	player.global_position = new_location

## Get the position of a particular door.
func get_door_position(new_door_name: String) -> Vector2:
	for door: Door in doors:
		if door.door_name == new_door_name:
			return door.global_position
	# If the target door didn't exist anywhere in the room, report the issue
	push_warning("Room: Door '%s' does not exist in this room" % new_door_name)
	return Vector2(0, 0)
