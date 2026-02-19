extends TileMapLayer



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt(1)
		print("Hazard: The player hit '%s'" % self.name)
	pass # Replace with function body.
