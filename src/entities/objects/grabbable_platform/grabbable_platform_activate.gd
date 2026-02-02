extends Area2D

signal platform_clawed

## Signal up the companion action request.
func companion_action_triggered() -> void:
	platform_clawed.emit()
