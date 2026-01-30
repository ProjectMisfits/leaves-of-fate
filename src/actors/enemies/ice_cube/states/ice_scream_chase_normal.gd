extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Chase Normal State")
	pass


func _update(delta: float) -> void:
	agent.move_normal(delta)
	agent.check_player_visible()
	agent.check_reached_player()
	pass
