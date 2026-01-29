extends LimboState

## Resume the platform when the companion ability is used.
func companion_action_triggered() -> void:
	agent.resume_platform()
