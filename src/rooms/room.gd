class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## Triggered when the player is moving to a new room.
signal swap_room(path_to_target_room: String, target_door_name: String)

## An array containing all Doors in this Room that lead to other Rooms.
var doors: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager._play_song(load("res://assets/music/PH-Joyful-120bpm-4_4-loop.ogg"))
	AmbianceManager._load_ambiance(load("res://assets/ambiance/resources/PH-Ambiance-1.tres"))
	# Connect each Door's entered signal to this Room's room swap function
	doors = $Doors.get_children()
	for door: Door in doors:
		door.player_entered_door.connect(_on_player_entered_door)

## Initiate room swap on player entering a Door.
func _on_player_entered_door(door: Door) -> void:
	# Check whether the door has a destination first.
	if (!door.path_to_target_room != ""):
		push_warning("Room: The target room of door '%s' in room '%s' is not set!" % [door.path_to_target_room, name])
		return
	AmbianceManager.stop()
	# Since the path to the target room is valid, initiate the load request.
	print("Room: Player entered door '%s'. Requesting load of target room '%s'" % [door.door_name, door.path_to_target_room])
	swap_room.emit(door.path_to_target_room, door.target_door_name)

## Spawn the player at the specified Door.
func spawn_player(target_door_name: String) -> void:
	# Check the name of the target door.
	# If it exists in this room, spawn the player there.
	for door: Door in doors:
		if door.door_name == target_door_name:
			print("Room: Spawning player in room '%s' at door '%s' with position '%s'" % [name, target_door_name, door.position])
			var player: Player = load("res://src/actors/characters/player/player.tscn").instantiate()
			add_child(player)
			player.global_position = door.position
			return
	
	# If the target door didn't exist anywhere in the room, report the issue.
	push_warning("Room: Target door '%s' does not exist in room '%s'." % [target_door_name, name])
