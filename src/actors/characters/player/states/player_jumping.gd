extends LimboState

func _enter() -> void:
	print("Player State Transition: to_jumping")
	agent.jump()

func _update(_delta: float) -> void:
	agent.check_dashing_state()
	agent.check_falling_state()
	
	agent.move_horizontal_air()
