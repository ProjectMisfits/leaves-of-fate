extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(delta: float) -> void:
	pass

func companion_action_triggered()->void:
	agent.ungrab()
