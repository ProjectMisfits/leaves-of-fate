class_name BronzePipe extends Node2D
## A bronze pipe that the player can only enter when in leaf mode. When entered, moves the player along the path of the pipe until they reach the exit.
## When in a bronze pipe, the player has no input control.

## A reference to the PathFollow2D node that will follow the pipe's path.
@onready var _pipe_path_follower: PathFollow2D = %PathFollow2D

## A reference to the visual that shows when the player is in a pipe.
@onready var _pipe_path_visual: ColorRect = $Path2D/PathFollow2D/ColorRect

## The speed at which bronze pipes progress. Represents the number of pixels the path advances per second. 
var _speed: float = 100.0

## Whether the player is currently traveling through this bronze pipe.
var _player_in_pipe: bool = false

## A reference to the player.
var _player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pipe entered signal to enter pipe function.
	$BronzePipeTrigger.pipe_entered.connect(_enter_pipe)

func _physics_process(delta: float) -> void:
	# Only do pipe logic if there is a player in the pipe
	if _player_in_pipe:
		if _at_pipe_path_end():
			# If the player is at the end of the pipe path, exit the pipe
			_exit_pipe()
		else:
			# Otherwise progress the path
			_progress_pipe_path(delta)

## Get the current progress ratio of the pipe path follower.
func _at_pipe_path_end() -> bool:
	return _pipe_path_follower.get_progress_ratio() >= 1.0

## Progress the pipe visual along the pipe path based on delta.
func _progress_pipe_path(delta: float) -> void:
	_pipe_path_follower.progress += delta * _speed

## Swap to "pipe mode" on entering a bronze pipe.
func _enter_pipe(player: Player) -> void:
	# Set local player reference
	_player = player
	# Disable player input
	# Hide player
	player.hide()
	# Show animation or particle visual of entering pipe
	# Show pipe visual
	_pipe_path_visual.show()
	# Set player in pipe to true
	_player_in_pipe = true
	# Have pipe visual follow pipe path
	# When path follow reaches end, swap to exiting pipe

	pass

## Swap out of "pipe mode" when exiting a pipe.
func _exit_pipe() -> void:
	# Set player in pipe to false
	_player_in_pipe = false
	# Disable pipe visual
	_pipe_path_visual.hide()
	# Show animation or particle visual of exiting pipe
	# Show player
	_player.show()
	# Enable player input
