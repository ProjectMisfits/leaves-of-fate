extends LimboState

## Stop the platform when the companion ability is used.
func companion_action_triggered() -> void:
	agent.stop_platform()
