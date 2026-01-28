class_name IceSpikeBall extends Area2D
## A big ice spike ball that hurts the player when they hit it.

## Triggers when the player enters the area of the obstacle.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		print("Hazard: The player hit '%s'" % self.name)
	pass # Replace with function body.
