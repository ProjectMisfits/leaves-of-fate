extends LimboState

# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	agent.animation_player.play("ice_scream_charge")


func _update(delta: float) -> void:
	agent.move_normal(delta)
	agent.check_wall()
