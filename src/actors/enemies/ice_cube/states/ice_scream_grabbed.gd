extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Grabbed State")
	agent.grab()
	pass


func _update(delta: float) -> void:
	agent.check_release()
	pass
