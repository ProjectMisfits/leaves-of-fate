extends LimboState

func _enter() -> void:
	print("Player State Transition: to_dashing")
	agent.dash()

func _update(_delta: float) -> void:
	pass
	#agent.check_dashing_state()
	#agent.check_falling_state()
	#
	#agent.move_horizontal_air()
