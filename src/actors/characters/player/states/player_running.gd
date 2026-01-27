extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_running")
	pass

func _update(_delta: float) -> void:
	agent.check_talk()
	agent.check_dashing_state()
	agent.check_shimmying_state()
	agent.check_jumping_state()
	agent.check_airborne_state()
	agent.check_idle_state()
	
	agent.move_horizontal_ground()
