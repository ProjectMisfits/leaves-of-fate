extends LimboState

func _enter() -> void:
	print("Player State Transition: to_falling")

func _update(_delta: float) -> void:
	agent.check_dashing_state()
	agent.check_jumping_state()
	agent.check_running_state()
	agent.check_idle_state()
	
	agent.move_horizontal_air()
