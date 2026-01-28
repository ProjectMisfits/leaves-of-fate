class_name Noclip extends PanelContainer
## A debug panel for the game that allows developers to teleport between rooms.

## A reference to the VBoxContainer the room dropdown exists in.
@onready var dropdown: OptionButton = $VBoxContainer/OptionButton

## An array containing the paths to all rooms in the project.
var room_paths: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_populate_room_dropdown()

## Populate the noclip panel with all rooms in the project.
func _populate_room_dropdown() -> void:
	var room_path: String = "res://src/rooms/"
	var room_folders: PackedStringArray = DirAccess.open(room_path).get_directories()
	for room_folder: String in room_folders:
		var room_scenes: PackedStringArray = DirAccess.open(room_path + room_folder + '/').get_files()
		for room_scene: String in room_scenes:
			dropdown.add_item(room_scene)
			var full_room_path: String = room_path + room_folder + '/' + room_scene
			room_paths.append(full_room_path)

## Triggered when a noclip menu option is selected.
## Teleport to room on selecting an option.
func _on_option_button_item_selected(index: int) -> void:
	# Check if we're in Gameplay. If we're in anything but gameplay, use SceneManager to swap to gameplay.
	if SceneManager.current_scene is not Gameplay:
		SceneManager.swap_scenes("res://src/gameplay/gameplay.tscn", null, SceneManager.current_scene)
	
	# If the player isn't already in the selected room,
	# tell Gameplay that we want to load the selected room.
	if !room_paths[index].contains(SceneManager.current_scene.current_room.name):
		SceneManager.current_scene._on_swap_room(room_paths[index], 'enter')
	
