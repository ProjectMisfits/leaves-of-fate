class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## Triggered when the player is moving to a new room.
signal swap_room(path_to_target_room: String, target_door_name: String)

## An array containing all Doors in this Room that lead to other Rooms.
var doors: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect each Door's entered signal to this Room's room swap function
	doors = $MidgroundLayer/Doors.get_children()
	for door: Door in doors:
		door.player_entered_door.connect(_on_player_entered_door)
	
	# If the room is being run standalone, we have to make sure the player gets instantiated.
	if get_tree().current_scene == self:
		var player: Player = preload("res://src/actors/characters/player/player.tscn").instantiate()
		spawn_player(player, 'enter')

## Initiate room swap on player entering a Door.
func _on_player_entered_door(door: Door) -> void:
	# Check whether the door has a destination first.
	if (door.path_to_target_room == ""):
		push_warning("Room '%s': Door '%s' does not have a target room set!" % [name, door.door_name])
		return
	
	# Since the path to the target room is valid, emit room load signal
	print("Room '%s': Player interacted with door '%s'" % [name, door.door_name])
	swap_room.emit(door.path_to_target_room, door.target_door_name)

## Spawn the player at the specified Door.
func spawn_player(player: Player, target_door_name: String) -> void:
	# Check the name of the target door against the doors in this room
	# If it exists in this room, add the player to the room and move it to the correct location
	for door: Door in doors:
		if door.door_name == target_door_name:
			print("Room '%s': Placing player at door '%s'" % [name, target_door_name])
			$MidgroundLayer/PlayerHolder.add_child(player)
			player.global_position = door.position
			
			# Update the camera limits to match the room
			player.get_node("Camera").update_camera_limits($BackgroundLayer/Background)
			return
	
	# If the target door didn't exist anywhere in the room, report the issue
	push_warning("Room '%s': Door '%s' does not exist in this room" % [name, target_door_name])

## Remove the player from this Room.
func despawn_player(player: Player) -> void:
	$MidgroundLayer/PlayerHolder.remove_child(player)
