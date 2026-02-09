extends "res://src/entities/objects/wind_zone/wind_zone.gd"


## If the Player is in the Area2D, gain/drain their wind.
func _physics_process(delta: float) -> void:
	if (_player == null):
		return
	
	var _new_wind_value: float = _player.leaf_meter	## The new value to set the Player's Leaf Meter to.
	
	match mode:
		wind_zone_mode.GAIN:
			_new_wind_value += _wind_gain_rate * delta
		wind_zone_mode.DRAIN:
			_new_wind_value -= _wind_drain_rate * delta
		_:
			return
			
	if _player.state_machine.get_active_state() == _player.dashing_state:
		_player.set_leaf_meter(_new_wind_value)

func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		_player = body
		_player.set_can_build_leaf(false)

## If body is the Player, remove Player reference & stop wind gain/drain
func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		_player.set_can_build_leaf(true)
		_player = null
