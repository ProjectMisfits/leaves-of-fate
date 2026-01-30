extends LimboState
## Grabbed state for grabbable entities

## If the entity is grabbed and the companion action is triggered, ungrab the entity.
func companion_action_triggered()->void:
	agent.ungrab()
