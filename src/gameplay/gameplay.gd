class_name Gameplay extends Node2D
## Wrapper for gameplay scenes during runtime.
## Manages scenes like the current Room, HUD, Camera, menus.

## A reference to the player.
var player: Player = preload("res://src/entities/actors/player/player.tscn").instantiate()

## A Node2D that acts as a persistent parent of the Room the player is in.
@onready var room_holder: Node2D = $%RoomHolder
## The Room the player is currently in.
var current_room: Room = null

## A reference to the MenuHolder CanvasLayer.
@onready var menu_holder: CanvasLayer = $MenuHolder
## A reference to the pause menu scene.
@onready var pause_menu: PauseMenu = preload("res://src/ui/pause_menu/pause_menu.tscn").instantiate()
## A reference to the settings menu scene.
@onready var settings_menu: SettingsMenu = preload("res://src/ui/settings_menu/settings_menu.tscn").instantiate()
## A reference to the controls menu scene.
@onready var controls_menu: ControlsMenu = preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate()
## A reference to the volume menu scene.
@onready var volume_menu: VolumeMenu = preload("res://src/ui/settings_menu/volume_menu/volume_menu.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the camera manager.
	CameraManager.initialize_camera($%PhantomCamera2D, $%Camera2D)
	
	# Set the starting Room
	_update_current_room()
	
	# Spawn the player at the first door now that the room has been loaded
	current_room.spawn_player(player, 'enter')
	# Connect phantom camera to player
	CameraManager.set_target(player)
	
	# Connect the player death signal to the respawn player function
	player.player_knocked_out.connect(respawn_player)
	
	# Passes player to the Hud so that Hud can update based on player actions
	$%Hud.set_player(player)
	
	# Connect UI menu signals
	_connect_menu_signals()

# Called once every physics tick.
func _physics_process(_delta: float) -> void:
	DebugMenu.add_debug_property("Current Room", current_room.name, 0)

## Update the reference to the current scene.
func _update_current_room() -> void:
	# Get the last child of RoomHolder, as that will always be the current room.
	current_room = room_holder.get_child(-1) as Room
	# Because the room was replaced, we have to update the connected signal.
	# But only if the connection doesn't already exist.
	if not current_room.swap_room.is_connected(_on_swap_room):
		current_room.swap_room.connect(_on_swap_room)

## Swap to the specified Room and unload the current Room.
func _on_swap_room(path_to_target_room: String, target_door_name: String) -> void:
	# Disconnect camera from player
	CameraManager.clear_target()
	
	# Remove player from current room
	current_room.despawn_player(player)
	# Call autoload SceneManager to swap the room
	var target_room_loaded: int = SceneManager.swap_scenes(path_to_target_room, $RoomHolder, current_room)
	# Make sure the load succeeded before continuing the swap
	if (target_room_loaded != 0):
		return
	
	# Update the current room
	_update_current_room()
	# Add player to new current room and place them at correct door
	current_room.spawn_player(player, target_door_name)
	
	# Reconnect camera to player
	CameraManager.set_target(player)

## Resets the Player's stats & respawns them at the last door they exited.
func respawn_player() -> void:
	player.reset_stats()
	current_room.respawn_player(player)

## UI FUNCTIONALITY

func _connect_menu_signals() -> void:
	# Connect pause menu
	pause_menu.get_node("%ResumeButton").button_up.connect(_close_pause_menu)
	pause_menu.get_node("%SettingsButton").button_up.connect(_open_settings_menu)
	pause_menu.get_node("%QuitButton").button_up.connect(_quit_to_main_menu)
	# Connect settings menu
	settings_menu.get_node("%ControlsButton").button_up.connect(_open_controls_menu)
	settings_menu.get_node("%VolumeButton").button_up.connect(_open_volume_menu)
	settings_menu.get_node("%BackButton").button_up.connect(_close_settings_menu)
	# Connect controls menu
	controls_menu.get_node("%BackButton").button_up.connect(_close_controls_menu)
	# Connect volume menu
	volume_menu.get_node("%BackButton").button_up.connect(_close_volume_menu)

## Toggle the game's pause state.
func toggle_pause() -> void:
	if (!get_tree().paused):
		# pause entire tree and open pause menu
		_open_pause_menu()
	else:
		_close_pause_menu()

## Open pause menu
func _open_pause_menu() -> void:
	get_tree().paused = true
	menu_holder.add_child(pause_menu)
	pause_menu.get_node("%ResumeButton").grab_focus.call_deferred()

## Close pause menu
func _close_pause_menu() -> void:
	for menu: Control in menu_holder.get_children():
		menu_holder.remove_child(menu)
	get_tree().paused = false

# Opens settings menu from pause menu
func _open_settings_menu() -> void:
	menu_holder.add_child(settings_menu)
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()

# Close setting menu
func _close_settings_menu() -> void:
	pause_menu.get_node("%ResumeButton").grab_focus.call_deferred()
	menu_holder.remove_child(settings_menu)

# Opens volume menu from settings menu
func _open_volume_menu() -> void:
	menu_holder.add_child(volume_menu)
	volume_menu.get_node("%MasterSlider").grab_focus.call_deferred()

# Closes volume menu
func _close_volume_menu() -> void:
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(volume_menu)

# Opens controls menu from settings menu
func _open_controls_menu() -> void:
	menu_holder.add_child(controls_menu)
	controls_menu.get_node("%BackButton").grab_focus.call_deferred()

# Closes controls menu 
func _close_controls_menu() -> void:
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(controls_menu)

## Quits game from pause menu
func _quit_to_main_menu() -> void:
	# unpauses tree and then switches out of gameplay scene to main menu scene 
	get_tree().paused = false
	SceneManager.swap_scenes("res://src/ui/main_menu/main_menu.tscn", null, self)
