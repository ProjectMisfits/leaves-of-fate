class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## Triggered when the player is moving to a new room.
signal swap_room(path_to_target_room: String, target_door_name: String)

## An array containing all Doors in this Room that lead to other Rooms.
var doors: Array[Door]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect each Door's entered signal to this Room's room swap function
	doors = $Doors.get_children() as Array[Door]
	for door: Door in doors:
		door.player_entered_door.connect(_on_player_entered_door)

## Initiate room swap on player entering a Door.
func _on_player_entered_door(door: Door) -> void:
	print("Room: Player entered door '%s'. Loading target room '%s'" % door.door_name, door.path_to_target_room)
	swap_room.emit(door.path_to_target_room, door.target_door_name)

## Spawn the player at the specified Door.
func spawn_player(target_door_name: String) -> void:
	# Check the name of the target door.
	# If it exists in this room, spawn the player there.
	for door: Door in doors:
		if door.door_name == target_door_name:
			print("Room: Found target door '%s'" % target_door_name)
