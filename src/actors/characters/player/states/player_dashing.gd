extends LimboState

func _enter() -> void:
	print("Player State Transition: to_dashing")
	agent.dash()

func _update(_delta: float) -> void:
	if (not agent.dashing):
		agent.check_airborne_state()
		agent.check_running_state()
		agent.check_idle_state()
