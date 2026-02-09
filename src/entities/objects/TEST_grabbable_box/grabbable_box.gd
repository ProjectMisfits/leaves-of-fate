## Rotating box used for testing the Player's grab action functionality.
extends StaticBody2D

var _grabbed: bool = false	## If True, stop rotating.


func _physics_process(delta: float) -> void:
	if not _grabbed:
		rotation += TAU * delta

## Set grabbed boolean to True.
func _grab() -> void:
	_grabbed = true

	
	

## Set grabbed boolean to False.
func _ungrab() -> void:

	_grabbed = false
