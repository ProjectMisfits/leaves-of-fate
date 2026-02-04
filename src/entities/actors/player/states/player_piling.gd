extends LimboState

func _enter() -> void:
	#print("Player State Transition: to_pileing")
	agent.animation_player.play("player_leaf_pile")
	agent.set_collision_mask_value(8,false)
	agent.collision_shape_2d.shape = agent.collision_dash
	agent.velocity.y = 0.0

func _update(delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed(&"dash") or (agent.leaf_meter <= 0) or agent.cutscene_mode):
		agent.check_airborne_state()
		agent.check_running_state()
		agent.check_idle_state()
	
	agent.velocity.y += agent.pile_gravity * delta
	agent.velocity.y = clampf(agent.velocity.y, -INF, agent.pile_terminal_velocity) # velocity cannot exceed terminal velocity
	
	if (agent.is_on_floor()):
		agent.move_horizontal_pile_ground(delta)
	else:
		agent.move_horizontal_pile_air(delta)

func _exit() -> void:
	agent.set_collision_mask_value(8,true)
	agent.collision_shape_2d.shape = agent.collision_normal
