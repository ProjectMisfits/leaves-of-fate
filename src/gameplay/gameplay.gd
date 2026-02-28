class_name Gameplay extends Node
## Wrapper for gameplay scenes during runtime.
## Manages scenes like the current Room, HUD, Camera, menus.

## A holder node for the room the player is currently in.
@onready var room_holder: Node2D = %RoomHolder
## The room the player is currently in.
@onready var current_room: Room
## The path to the current room's file. Used for resetting rooms.
var current_room_path: String = ""

## The starting room of the game.
@export_file("*_room.tscn") var first_room_path: String = "res://src/rooms/01_great_hall/01_GreatHall_a_Intro_room.tscn"
## Used to make sure the first room setup happens only once.
var first_setup: bool = true

## A reference to the HUD.
@onready var hud: Hud = $UILayer/Hud
## A reference to the MenuHolder CanvasLayer.
@onready var menu_holder: Control = $UILayer/MenuHolder
## A reference to the pause menu scene.
@onready var pause_menu: PauseMenu = preload("res://src/ui/pause_menu/pause_menu.tscn").instantiate()
## A reference to the settings menu scene.
@onready var settings_menu: SettingsMenu = preload("res://src/ui/settings_menu/settings_menu.tscn").instantiate()
## A reference to the controls menu scene.
@onready var controls_menu: ControlsMenu = preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate()
## A reference to the volume menu scene.
@onready var volume_menu: VolumeMenu = preload("res://src/ui/settings_menu/volume_menu/volume_menu.tscn").instantiate()
## An audio player for the select sound effect.
@onready var select_audio: AudioStreamPlayer = $Audio/SelectAudio

## The spawn/respawn/checkpoint location for the player.
var player_spawn_location: Vector2

func _get_player_pos() -> Vector2:
	return current_room.player.get_eye_position()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the camera manager.
	CameraManager.initialize_camera(%PhantomCamera2D, %Camera2D)
	
	# Connect the player knocked out signal.
	EventBus.player_knocked_out.connect(_on_player_knocked_out)
	
	# Connect the scene swap finished signal to the first room setup method.
	SceneManager.scene_swap_ended.connect(_first_room_setup)
	
	# Connect UI menu signals
	_connect_menu_signals()

## Set up the first room of the game.
func _first_room_setup() -> void:
	if first_setup:
		first_setup = false
		# Put the player in the first room.
		SceneManager.swap_scenes(first_room_path, room_holder, null)
		current_room = room_holder.get_child(0)
		_init_room(current_room.get_door_position('enter'))
		player_spawn_location = current_room.get_door_position('enter')
		current_room.player.unfreeze()

## Set the first room to load when gameplay starts.
func set_first_room(new_first_room_path: String) -> void:
	first_room_path = new_first_room_path

# Called once every physics tick.
func _physics_process(_delta: float) -> void:
	if is_instance_valid(current_room):
		DebugMenu.add_debug_property("Current Room", current_room.name, 0)

## Tear down a room before a swap.
func _tear_down_room() -> void:
	# Disconnect camera from player
	CameraManager.clear_target()

## Set up a room after a swap.
func _init_room(init_player_location: Vector2) -> void:
	
	# Connect room signals for rooms that don't have them connected yet
	if not current_room.swap_room.is_connected(_on_swap_room):
		current_room.swap_room.connect(_on_swap_room)
	# Set the room's camera limits
	CameraManager.set_limit(current_room.midground.get_path())
	# Reset hud state
	hud.reset_hud()
	# Connect the HUD to the new player
	hud.set_player(current_room.player)
	# Add player to the room and place them at correct door
	current_room.set_player_location(init_player_location)
	# Reconnect camera to player
	CameraManager.set_target(current_room.player)
	CameraManager.teleport()

## Swap to the specified Room and unload the current Room.
func _on_swap_room(target_room_path: String, target_door_name: String) -> void:
	current_room.player.freeze()
	# Begin a screen transition.
	await SceneManager.add_screen_transition("circle", _get_player_pos())
	_tear_down_room()
	SceneManager.swap_scenes(target_room_path, room_holder, current_room)
	# Update the current room
	current_room = room_holder.get_child(-1) as Room
	_init_room(current_room.get_door_position(target_door_name))
	current_room_path = target_room_path
	player_spawn_location = current_room.get_door_position(target_door_name)
	# Wait a frame and then finish the screen transition.
	await get_tree().process_frame
	await SceneManager.remove_screen_transition(_get_player_pos())
	
	current_room.player.unfreeze()

## When the player is knocked out, reset the room and put the player at their last spawn location.
func _on_player_knocked_out() -> void:
	# Begin a screen transition.
	await SceneManager.add_screen_transition("circle", _get_player_pos())
	_tear_down_room()
	SceneManager.swap_scenes(current_room_path, room_holder, current_room)
	# Update the current room
	current_room = room_holder.get_child(-1) as Room
	_init_room(player_spawn_location)
	current_room.player.play_spawn_particles()
	# Wait a frame and then finish the screen transition.
	await get_tree().process_frame
	await SceneManager.remove_screen_transition(_get_player_pos())
	current_room.player.unfreeze()

## UI FUNCTIONALITY

## Connect each menu screen's buttons to the desired menus
func _connect_menu_signals() -> void:
	# Connect pause menu
	pause_menu.get_node("%ResumeButton").button_up.connect(_close_pause_menu)
	pause_menu.get_node("%SettingsButton").button_up.connect(_open_settings_menu)
	pause_menu.get_node("%QuitButton").button_up.connect(_quit_to_main_menu)
	# Connect settings menu
	settings_menu.get_node("%ControlsButton").button_up.connect(_open_controls_menu)
	settings_menu.get_node("%VolumeButton").button_up.connect(_open_volume_menu)
	settings_menu.get_node("%BackButton").button_up.connect(close_settings_menu)
	# Connect controls menu
	controls_menu.get_node("%BackButton").button_up.connect(close_controls_menu)
	# Connect volume menu
	volume_menu.get_node("%BackButton").button_up.connect(close_volume_menu)

## Toggle the game's pause state.
func toggle_pause() -> void:
	if (!get_tree().paused):
		# pause entire tree and open pause menu
		_open_pause_menu()
	else:
		_close_pause_menu()

## Open pause menu
func _open_pause_menu() -> void:
	select_audio.play()
	await select_audio.finished
	get_tree().paused = true
	menu_holder.add_child(pause_menu)
	pause_menu.get_node("%ResumeButton").grab_focus.call_deferred()

## Close pause menu
func _close_pause_menu() -> void:
	select_audio.play()
	for menu: Control in menu_holder.get_children():
		menu_holder.remove_child(menu)
	get_tree().paused = false

# Opens settings menu from pause menu
func _open_settings_menu() -> void:
	select_audio.play()
	menu_holder.add_child(settings_menu)
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()

# Close setting menu
func close_settings_menu() -> void:
	select_audio.play()
	pause_menu.get_node("%ResumeButton").grab_focus.call_deferred()
	menu_holder.remove_child(settings_menu)

# Opens volume menu from settings menu
func _open_volume_menu() -> void:
	select_audio.play()
	menu_holder.add_child(volume_menu)
	volume_menu.get_node("%MasterSlider").grab_focus.call_deferred()

# Closes volume menu
func close_volume_menu() -> void:
	select_audio.play()
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(volume_menu)

# Opens controls menu from settings menu
func _open_controls_menu() -> void:
	select_audio.play()
	menu_holder.add_child(controls_menu)
	controls_menu.get_node("%BackButton").grab_focus.call_deferred()

# Closes controls menu 
func close_controls_menu() -> void:
	select_audio.play()
	settings_menu.get_node("%ControlsButton").grab_focus.call_deferred()
	menu_holder.remove_child(controls_menu)

## Quits game from pause menu
func _quit_to_main_menu() -> void:
	select_audio.play()
	#await select_audio.finished
	# unpauses tree and then switches out of gameplay scene to main menu scene 
	get_tree().paused = false
	SceneManager.swap_scenes_with_transition("res://src/ui/main_menu/main_menu.tscn", null, self)
