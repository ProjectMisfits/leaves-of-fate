extends LimboState
## Ungrabbed state for grabbable entities

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(_delta: float) -> void:
	# If the entity is ungrabbed, rotate the sprite to show that it is ungrabbed.
	agent.rotate_sprite()

## If the entity is ungrabbed and the companion action is triggered, grab the entity.
func companion_action_triggered() -> void:
	agent.grab()
