extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Idle State")
	agent.animation_player.play("ice_scream_idle")
	agent.reset()
	


func _update(delta: float) -> void:
	agent.move_idle(delta)
	agent.check_for_player()


	
