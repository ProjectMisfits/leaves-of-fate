extends LimboState

func _enter() -> void:
	print("Player State Transition: to_idle")

func _update(_delta: float) -> void:
	agent.check_running_state()
