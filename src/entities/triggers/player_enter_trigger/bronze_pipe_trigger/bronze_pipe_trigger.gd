class_name BronzePipeTrigger extends PlayerEnterTrigger
## A trigger for sending the player through bronze pipes. Activates on player enter if and only if they're in leaf mode.

signal pipe_entered(pipe_enterer: Player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_trigger = _enter_pipe

## Begin sending the player through the bronze pipe.
func _enter_pipe() -> void:
	# Check if the player is in leaf mode
	# If so, emit a pipe entered signal with the player for the pipe to catch
	pass
	pipe_entered.emit(player)
