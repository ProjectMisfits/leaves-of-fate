class_name BronzePipe extends Node2D
## A bronze pipe that the player can only enter when in leaf mode. When entered, moves the player along the path of the pipe until they reach the exit.
## When in a bronze pipe, the player has no input control.

## A reference to the PathFollow2D node that will follow the pipe's path.
@onready var pipe_path_follower: PathFollow2D = %PathFollow2D

## The speed at which bronze pipes progress. Represents the number of pixels the path advances per second. 
var speed: float = 100.0

func _physics_process(delta: float) -> void:
	_progress_pipe_path(delta)

## Progress the visual along the pipe path based on delta.
func _progress_pipe_path(delta: float) -> void:
	pipe_path_follower.progress += delta * speed

## Swap to "pipe mode" on entering a bronze pipe.
func _enter_pipe() -> void:
	# Disable player input
	# Hide player
	# Show animation of entering pipe
	# Show pipe visual
	# Have pipe visual follow pipe path
	# When path follow reaches end, swap to exiting pipe
	# Disable pipe visual
	# Show animation of exiting pipe
	# Show player
	# Enable player input
	pass
