class_name BronzePipe extends Node2D
## A bronze pipe that the player can only enter when in leaf mode. When entered, moves the player along the path of the pipe until they reach the exit.
## When in a bronze pipe, the player has no input control.

## A reference to the pipe path curve.
@onready var _pipe_path_curve: Curve2D = $Path2D.curve

## A reference to the PathFollow2D node that will follow the pipe's path.
@onready var _pipe_path_follower: PathFollow2D = %PathFollow2D

## A reference to the visual that shows when the player is in a pipe.
@onready var _pipe_path_visual: ColorRect = %ColorRect

## The speed at which bronze pipes progress. Represents the percentage of the path that it advances each second. Here, 1.0 means 100% of the path will be traversed in one second.
@export_range(0.0, 1.0, 0.01) var _speed_percentage: float = 1.0

## Whether the player is currently traveling through this bronze pipe.
var _player_in_pipe: bool = false

## A reference to the player.
var _player: Player = null

## A reference to the RemoteTransform2D node used to control the player when in a pipe.
@onready var _player_pipe_transform: RemoteTransform2D = %RemoteTransform2D

func _ready() -> void:
	# Set up the pipe texture along the pipe's path.
	for idx: int in _pipe_path_curve.point_count:
		$Path2D/Line2D.add_point(_pipe_path_curve.get_point_position(idx))
	# Put the cap textures at the start and end of the pipe.
	var start_cap_sprite: Sprite2D = Sprite2D.new()
	start_cap_sprite.texture = preload("res://assets/entities/objects/bronze_pipe/PipeStraight-01-capstart.PNG")
	start_cap_sprite.position = _pipe_path_curve.get_point_position(0)
	start_cap_sprite.rotate(_pipe_path_curve.get_point_position(0).angle_to(_pipe_path_curve.get_point_position(1)))
	start_cap_sprite.scale = Vector2(1.5, 1.5)
	add_child(start_cap_sprite)
	var end_cap_sprite: Sprite2D = Sprite2D.new()
	end_cap_sprite.texture = preload("res://assets/entities/objects/bronze_pipe/PipeStraight-01-capend.PNG")
	end_cap_sprite.position = _pipe_path_curve.get_point_position(_pipe_path_curve.point_count - 1)
	end_cap_sprite.rotate(_pipe_path_curve.get_point_position(_pipe_path_curve.point_count - 2).angle_to_point(_pipe_path_curve.get_point_position(_pipe_path_curve.point_count - 1)))
	end_cap_sprite.scale = Vector2(1.5, 1.5)
	add_child(end_cap_sprite)

# Called every physics tick.
func _physics_process(delta: float) -> void:
	# Only do pipe logic if the player is in the pipe
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
	_pipe_path_follower.progress_ratio += delta * _speed_percentage

## Swap to "pipe mode" on entering a bronze pipe.
func _enter_pipe(player: Player) -> void:
	# Set local player reference
	_player = player
	# Connect RemoteTransform2D to player so it follows the visual while hidden
	_player_pipe_transform.remote_path = _player.get_path()
	# Disable player input
	_player.disable_player_input()
	# Hide player
	_player.hide()
	# Show animation or particle visual of entering pipe
	# Show pipe visual
	_pipe_path_visual.show()
	# Set player in pipe to true
	_player_in_pipe = true

## Swap out of "pipe mode" when exiting a pipe.
func _exit_pipe() -> void:
	# Set player in pipe to false
	_player_in_pipe = false
	# Disable pipe visual
	_pipe_path_visual.hide()
	# Show animation or particle visual of exiting pipe
	# Reset player velocity so it launches out of the pipe instead of wonkily at the ground due to gravity
	var new_player_velocity: Vector2 = Vector2.RIGHT.rotated(_pipe_path_curve.get_point_position(_pipe_path_curve.point_count - 2).angle_to_point(_pipe_path_curve.get_point_position(_pipe_path_curve.point_count - 1))) * _player.dash_end_velocity_multiplier * _pipe_path_curve.get_baked_length()
	_player.velocity = new_player_velocity
	# Enable player input
	_player.enable_player_input()
	# Disconnect the RemoteTransform2D from the player
	_player_pipe_transform.remote_path = ""
	# Reset the pipe's progress ratio
	_pipe_path_follower.progress_ratio = 0.0
	# Show player
	_player.show()
	# Clear local player reference
	_player = null
