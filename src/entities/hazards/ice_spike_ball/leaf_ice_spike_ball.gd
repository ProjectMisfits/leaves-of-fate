extends IceSpikeBall

## Triggers when the player enters the area of the obstacle.
func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.state_machine.get_active_state() != body.dashing_state:
		body.hurt(1)
		print("Hazard: The player hit '%s'" % self.name)
	pass # Replace with function body.
