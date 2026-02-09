extends Node
## Manages the scene tree during runtime. Handles swapping scenes, particularly between menus and gameplay.

## The current first child scene of the tree root.
var current_scene: Node = null

## Wether scenes are currently being swapped out
var swap_in_progress: bool = false

## Reference to screen transition PackedScene
var screen_transition_scene: PackedScene = preload("res://src/ui/screen_transition/screen_transition.tscn")

## A reference to the current screen transition. If there are no active screen transitions, this variable is null.
var current_screen_transition: ScreenTransition = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().current_scene

# Called once on each physics tick.
func _physics_process(_delta: float) -> void:
	DebugMenu.add_debug_property("Current Scene", current_scene.name, 0)

## Swaps to the specified scene and unloads the specified scene.
## Returns -1 if the load failed for any reason and returns 0 if the load succeeded.
func swap_scenes(scene_to_load: String, load_as_child_of: Node, scene_to_unload: Node, transition_type: String = "fade_to_black") -> int:
	# Check that the specified scene to load exists.
	if not ResourceLoader.exists(scene_to_load, "PackedScene"):
		push_warning("SceneManager: Requested scene '%s' does not exist at path." % scene_to_load)
		return -1
	
	if swap_in_progress:
		push_warning("SceneManager: A scene is already being loaded!")
		return -1
	
	swap_in_progress = true
	
	# Start the screen transition.
	_add_screen_transition(transition_type)
	
	# Load the desired scene.
	var loaded_scene: Node = ResourceLoader.load(scene_to_load, "PackedScene").instantiate()
	
	# Check that the scene loaded correctly.
	if loaded_scene == null:
		push_warning("SceneManager: Requested scene '%s' did not load properly." % scene_to_load)
		swap_in_progress = false
		return -1
	
	# If no node was specified to load the scene as a child of, default to making it a child of the root node.
	if load_as_child_of == null: load_as_child_of = get_tree().root
	
	# Add the newly loaded scene to the scene tree.
	print("SceneManager: Loading scene '%s'" % loaded_scene)
	load_as_child_of.add_child(loaded_scene)
	
	# Unload the scene that is no longer needed.
	if scene_to_unload != null and scene_to_unload != get_tree().root:
		print("SceneManager: Unloading scene '%s'" % scene_to_unload)
		scene_to_unload.queue_free()
	
	# Update the current scene if the swap was made directly under the root node.
	if load_as_child_of == get_tree().root:
		current_scene = loaded_scene
	
	# Finish up the swap.
	_remove_screen_transition()
	swap_in_progress = false
	return 0

## Create a screen transition, add it to the scene tree, and initiate the animation.
func _add_screen_transition(transition_type: String) -> void:
	current_screen_transition = screen_transition_scene.instantiate()
	get_tree().root.add_child(current_screen_transition)
	current_screen_transition.start_transition(transition_type)
	# Wait for the animation to finish.
	await current_screen_transition.transition_animation_player.animation_finished
	
## Reverse the screen transition animation and remove the screen transition from the scene tree.
func _remove_screen_transition() -> void:
	# Reverse the screen transition animation.
	current_screen_transition.finish_transition()
	# Wait for the animation to finish.
	await current_screen_transition.transition_animation_player.animation_finished
	# Remove and reset the current screen transition.
	current_screen_transition.queue_free()
	current_screen_transition = null
