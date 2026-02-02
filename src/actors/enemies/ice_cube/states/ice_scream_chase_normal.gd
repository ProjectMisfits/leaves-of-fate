extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Chase Normal State")
	agent.ice_cube_sprite.modulate = Color(0.816, 0.346, 0.871, 1.0)
	


func _update(delta: float) -> void:
	agent.move_normal(delta)
	agent.check_player_visible()
	agent.check_reached_player()
