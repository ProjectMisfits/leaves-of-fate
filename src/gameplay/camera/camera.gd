class_name Camera extends Node2D
## A manager for the camera, its current target, position, and zoom.

## A reference to the phantom camera used to target objects.
@onready var phantom_camera: PhantomCamera2D = $PhantomCamera2D
## A reference to the 2D camera.
@onready var camera: Camera2D = $%Camera2D

## Set the camera's target.
func set_target(target: Node2D) -> void:
	phantom_camera.set_follow_target(target)

## Clear the camera's target.
func clear_target() -> void:
	phantom_camera.erase_follow_target()

## Move the camera's position (relative to the target).
func move(move_vector: Vector2) -> void:
	phantom_camera.move_local_x(move_vector.x)
	phantom_camera.move_local_y(move_vector.y)

## Reset the camera's position.

## Set the camera's zoom.

## Reset the camera's zoom.

## Set the camera's limits.
