extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:

	pass


func _update(delta: float) -> void:
	agent.move(delta)
	agent.check_reached()
	pass
