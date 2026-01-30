extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_running")
	agent.animation_player.play("player_walk_cycle")
	pass

func _update(_delta: float) -> void:

	agent.check_dashing_state()
	agent.check_piling_state()
	agent.check_jumping_state()
	agent.check_airborne_state()
	agent.check_idle_state()
	
	agent.move_horizontal_ground()
