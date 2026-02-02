extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_airborne")
	agent.animation_player.play("player_idle")
	pass

func _update(_delta: float) -> void:

	agent.check_dashing_state()
	agent.check_piling_state()
	agent.check_running_state()
	agent.check_idle_state()
	
	agent.move_horizontal_air()
