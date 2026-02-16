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

# Called once every physics tick.
func _physics_process(_delta: float) -> void:
	DebugMenu.add_debug_property("Current Scene", current_scene.name, 0)

## Remove the given scene from the scene tree.
func _unload_scene(scene_to_unload: Node) -> int:
	if scene_to_unload == null:
		# If the scene to unload is null, don't do anything. This can sometimes be intended behavior.
		return 0
	elif scene_to_unload == get_tree().root:
		# If the scene to unload is the scene tree root, report the error and abort
		push_error("SceneManager: Asked to unload scene tree root")
		return -1
	elif not is_instance_valid(scene_to_unload):
		# If the scene to unload is invalid, report the error and abort
		push_error("SceneManager: Asked to unload invalid scene")
		return -1
	else:
		# Otherwise follow through with the unload
		scene_to_unload.queue_free()
		return 0

## Add the given scene to the scene tree as a child of the given node.
## Returns null if the load was unsuccessful and a reference to the node otherwise.
func _load_scene(scene_to_load: String, load_as_child_of: Node) -> Node:
	# If the given scene to load the scene under is null, default to the tree root
	if load_as_child_of == null:
		load_as_child_of = get_tree().root
	
	if not is_instance_valid(load_as_child_of):
		# If the node to load the scene as a child of is invalid, report the error and abort
		push_error("SceneManager: Asked to load scene as a child of an invalid scene")
		return null
	elif not load_as_child_of.is_inside_tree():
		# If the not to load the scene as a child of is in the scene tree, report the error and abort
		push_error("SceneManager: Node to load scene as child of is not inside scene tree")
		return null
	elif not ResourceLoader.exists(scene_to_load, "PackedScene"):
		# If the scene to load does not exist, report the error and abort
		push_warning("SceneManager: Requested scene '%s' does not exist" % scene_to_load)
		return null
	else:
		# Otherwise follow through with the load
		var loaded_scene: Node = ResourceLoader.load(scene_to_load, "PackedScene").instantiate()
		if loaded_scene == null:
			# If the scene loaded incorrectly, report the error and abort
			push_warning("SceneManager: Requested scene '%s' did not load correctly" % scene_to_load)
			return null
		else:
			load_as_child_of.add_child(loaded_scene)
			if load_as_child_of == get_tree().root:
				current_scene = loaded_scene
			return loaded_scene

## Swaps to the specified scene and unloads the specified scene.
## Returns null if the swap failed for any reason, otherwise returns a reference to the newly loaded node.
func swap_scenes(scene_to_load: String, load_as_child_of: Node, scene_to_unload: Node) -> Node:
	if swap_in_progress:
		# If a swap is already in progress, report the issue and abort
		push_warning("SceneManager: A swap is already in progress")
		return null
	
	# Start the swap
	swap_in_progress = true
	
	# Unload the desired scene
	if _unload_scene(scene_to_unload) != 0:
		swap_in_progress = false
		return null
	
	# Load the desired scene
	var loaded_scene: Node = _load_scene(scene_to_load, load_as_child_of)
	if loaded_scene == null:
		swap_in_progress = false
		return null
	
	# If nothing failed, finish the swap
	swap_in_progress = false
	return loaded_scene

## Swap scenes, but during a screen transition.
## Use if you need to do a rote swap and don't have any additional teardown or setup you want to hide with a screen transition.
func swap_scenes_with_transition(scene_to_load: String, load_as_child_of: Node, scene_to_unload: Node, transition_type: String = "circle") -> Node:
	add_screen_transition(transition_type)
	var loaded_scene: Node = swap_scenes(scene_to_load, load_as_child_of, scene_to_unload)
	remove_screen_transition()
	return loaded_scene

## Create a screen transition, add it to the scene tree, and initiate the animation.
func add_screen_transition(transition_type: String) -> void:
	print("Transitioning out...", transition_type)
	current_screen_transition = screen_transition_scene.instantiate()
	get_tree().root.add_child(current_screen_transition)
	await current_screen_transition.start_transition(transition_type)
	print("Transition out finished!")

## Reverse the screen transition animation and remove the screen transition from the scene tree.
func remove_screen_transition() -> void:
	print("Transitioning in...")
	await current_screen_transition.finish_transition()
	get_tree().root.remove_child(current_screen_transition)
	current_screen_transition.queue_free()
	current_screen_transition = null
	print("Transition in finished!")
