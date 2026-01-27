extends LimboState

func _enter() -> void:
	agent.disable_companion_collision()
	
func _exit() -> void:
	agent.enable_companion_collision()

func _update(delta: float) -> void:
	#The player can release a plat form from anywhere
	if Input.is_action_just_pressed("companion"):
		agent.continue_platform()
		
