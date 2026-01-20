extends LimboState

func _enter() -> void:
	print("Player State Transition: to_idle")
	agent.time_since_on_floor = 0.0

func _update(_delta: float) -> void:
	agent.check_dashing_state()
	agent.check_jumping_state()
	agent.check_falling_state()
	agent.check_running_state()
