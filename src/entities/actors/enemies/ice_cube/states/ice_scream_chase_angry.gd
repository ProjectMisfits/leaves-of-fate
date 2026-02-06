extends LimboState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	print("Entered Chased Angry State")
	agent.ice_cube_sprite.modulate = Color(1.0, 0.0, 0.145, 1.0)
	agent.animation_player.play("ice_scream_charge")



func _update(delta: float) -> void:
	agent.move_angry(delta)
	agent.check_wall()
