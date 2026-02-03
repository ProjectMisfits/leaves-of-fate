extends Node2D
## A manager for the camera, its current target, position, and zoom. Primarily allows for easier cutscene scripting from dialogue resource files.

## A reference to the phantom camera used to target objects.
var phantom_camera: PhantomCamera2D
## A reference to the 2D camera.
var camera: Camera2D

## Initialize the camera nodes.
func initialize_camera(new_phantom_camera: PhantomCamera2D, new_camera: Camera2D) -> void:
	phantom_camera = new_phantom_camera
	camera = new_camera

## Set the camera's target.
func set_target(target: Node2D) -> void:
	phantom_camera.set_follow_target(target)

## Add a camera follow target.


## Clear the camera's target.
func clear_target() -> void:
	phantom_camera.erase_follow_target()

## Move the camera's position (relative to the target).
func move(move_vector: Vector2) -> void:
	phantom_camera.position += move_vector

## Reset the camera's position.

## Set the camera's zoom.
func set_zoom(new_zoom: Vector2) -> void:
	phantom_camera.set_zoom(new_zoom)

## Reset the camera's zoom.

## Set the camera's limits.
