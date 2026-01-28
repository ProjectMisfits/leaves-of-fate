extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Chased Angry State")
	pass


func _update(delta: float) -> void:
	agent.move(agent.CHARGE_SPEED_ANGRY,delta)
	agent.check_wall()
	pass
