extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	pass # Replace with function body.



func _update(delta: float) -> void:
	agent.rotate_sprite()
	pass

func companion_action_triggered()->void:
	agent.grab()
