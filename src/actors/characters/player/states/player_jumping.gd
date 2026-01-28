extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_jumping")
	agent.jump()

func _update(_delta: float) -> void:
	agent.check_talk()
	agent.check_dashing_state()
	agent.check_piling_state()
	
	if (agent.velocity.y >= 0.0):	# Can only transition into airborne once jump reaches peak
		agent.check_airborne_state()
	
	agent.move_horizontal_air()
