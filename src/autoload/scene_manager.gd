extends Node
## Manages the scene tree during runtime. Handles swapping scenes, particularly between menus and rooms during gameplay.

var current_scene: Node = null ## The scene currently being shown to the player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the current scene to the initial child of the root node.
	_update_current_scene()


## Update the reference to the current scene.
func _update_current_scene() -> void:
	current_scene = get_tree().current_scene


## Swaps to the specified scene and unloads the specified scene.
## Returns -1 if the load failed for any reason and returns 0 if the load succeeded.
func swap_scenes(scene_to_load: String, load_as_child_of: Node, scene_to_unload: Node) -> int:
	# Check that the specified scene to load exists.
	if not ResourceLoader.exists(scene_to_load, "PackedScene"):
		push_warning("SceneManager: Requested scene '%s' does not exist at path." % scene_to_load)
		return -1
	
	# Unload the scene that is no longer needed.
	if scene_to_unload != null and scene_to_unload != get_tree().root:
		print("SceneManager: Unloading scene '%s'" % scene_to_unload)
		scene_to_unload.queue_free()
	
	# Load the desired scene.
	var loaded_scene: Node = ResourceLoader.load(scene_to_load, "PackedScene").instantiate()
	
	# Check that the scene loaded correctly.
	if loaded_scene == null:
		push_warning("SceneManager: Requested scene '%s' did not load properly." % scene_to_load)
		return -1
	
	# If no node was specified to load the scene as a child of, default to making it a child of the root node.
	if load_as_child_of == null: load_as_child_of = get_tree().root
	
	# Add the newly loaded scene to the scene tree.
	print("SceneManager: Loading scene '%s'" % loaded_scene)
	load_as_child_of.add_child(loaded_scene)
	
	return 0
