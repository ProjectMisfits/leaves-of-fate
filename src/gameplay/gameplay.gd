class_name Gameplay extends Node2D
## Wrapper for gameplay scenes during runtime.
## Manages scenes like the current Room, HUD, Camera, menus.

## A Node2D that acts as a persistent parent of the Room the player is in.
@onready var room_holder: Node2D = $RoomHolder

## The Room the player is currently in.
var current_room: Room = null

## The player object.
var player: Player = preload("res://src/actors/characters/player/player.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the starting Room
	_update_current_room()
	# Spawn the player at the first door now that the room has been loaded
	current_room.spawn_player(player, 'enter')
	
	player.player_knocked_out.connect(respawn_player)

func _process(delta: float) -> void:
		_pause_game()

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
func _on_swap_room(path_to_target_room: String, target_door_name: String)-> void:
	# Remove player from current room
	current_room.remove_child(player)
	
	# Call autoload SceneManager to swap the room
	var target_room_loaded: int = SceneManager.swap_scenes(path_to_target_room, $RoomHolder, current_room)
	# Make sure the load succeeded before continuing the swap
	if (target_room_loaded != 0):
		return
	
	# Update the current room
	_update_current_room()
	# Add player to new current room and place them at correct door
	current_room.spawn_player(player, target_door_name)

## UI FUNCTIONALITY 
func _pause_game() -> void:
	if Input.is_action_just_pressed(&"pause"):
		get_tree().paused = true
		_open_pause_menu()

func _open_pause_menu() -> void:
	add_child(preload("res://src/ui/pause_menu/pause_menu.tscn").instantiate())
	
	$PauseMenu/CanvasLayer/Panel/ControlsContainer/ResumeButton.button_up.connect(_resume_game)
	$PauseMenu/CanvasLayer/Panel/ControlsContainer/QuitButton.button_up.connect(_quit_game)
	$PauseMenu/CanvasLayer/Panel/ControlsContainer/SettingsButton.button_up.connect(_open_settings)

func _resume_game() -> void:
	get_tree().paused = false
	$PauseMenu.queue_free()


func _quit_game() -> void:
	get_tree().paused = false 
	SceneManager.swap_scenes("res://src/ui/main_menu/main_menu.tscn", null, self)

func _open_settings() -> void:
	$PauseMenu.queue_free()
	add_child(preload("res://src/ui/settings_menu/settings_menu.tscn").instantiate())
	
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/BackButton.button_up.connect(_exit_settings)
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/VolumeButton.button_up.connect(_open_volume)
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.button_up.connect(_open_controls)

func _exit_settings() -> void:
	$SettingsMenu.queue_free()
	_open_pause_menu()

func _open_volume() -> void:
	$SettingsMenu.add_child(preload("res://src/ui/settings_menu/volume_menu/volume_menu.tscn").instantiate())
	$SettingsMenu.hide()
	
	$SettingsMenu/VolumeMenu/CanvasLayer/Panel/BackButton.button_up.connect(_close_volume)

func _close_volume() -> void:
	$SettingsMenu/VolumeMenu.queue_free()
	$SettingsMenu.show()
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.grab_focus.call_deferred()

func _open_controls() -> void:
	$SettingsMenu.add_child(preload("res://src/ui/settings_menu/controls_menu/controls_menu.tscn").instantiate())
	$SettingsMenu.hide()
	
	$SettingsMenu/ControlsMenu/CanvasLayer/Panel/BackButton.button_up.connect(_close_controls)

func _close_controls() -> void:
	$SettingsMenu/ControlsMenu.queue_free()
	$SettingsMenu.show()
	$SettingsMenu/CanvasLayer/Panel/ControlsContainer/ControlsButton.grab_focus.call_deferred()

# Resets the Player's stats & respawns them at the last door they exited.
func respawn_player() -> void:
	player.reset_stats()
	current_room.respawn_player(player)

