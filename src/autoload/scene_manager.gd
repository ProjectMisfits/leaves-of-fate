extends Node

## The current scene being shown to the player.
var current_scene: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().current_scene

## Swaps to the specified scene and unloads the specified scene.
func swap_scenes(scene_to_load: Node2D, scene_to_unload: Node2D) -> void:
	pass
