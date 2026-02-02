class_name Icicle extends StaticBody2D
## An icicle that hurts the player when they hit it. Can be stood on a little.

## Triggers when the player enters the area of the obstacle.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt(1)
		print("Hazard: The player hit '%s'" % self.name)
	pass # Replace with function body.
