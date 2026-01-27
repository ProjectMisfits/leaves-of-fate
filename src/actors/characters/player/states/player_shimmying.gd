extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_shimmying")
	agent.animated_sprite_2d.animation = &"shimmy"
	agent.velocity.y = 0.0

func _update(delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed(&"dash") or (agent.leaf_meter <= 0)):
		agent.check_airborne_state()
		agent.check_running_state()
		agent.check_idle_state()
	
	agent.velocity.y += agent.shimmy_gravity * delta
	agent.velocity.y = clampf(agent.velocity.y, -INF, agent.shimmy_terminal_velocity) # velocity cannot exceed terminal velocity
	
	if (agent.is_on_floor()):
		agent.move_horizontal_shimmy_ground()
	else:
		agent.move_horizontal_shimmy_air()

func _exit() -> void:
	agent.animated_sprite_2d.animation = &"player"
