extends LimboState

var turning: bool = false
var move_direction: Vector2 = Vector2.RIGHT
var input_direction: Vector2
var rad_angular_turn_speed: float

func _enter() -> void:
	#print("Player State Transition: to_dashing")
	agent.animation_player.play("player_leaf_dash")

	agent.collision_shape_2d.shape = agent.collision_dash
	for ps: GPUParticles2D in agent.dash_particles.get_children(): # Enable Leaf Dash particles
		ps.emitting = true
	
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	rad_angular_turn_speed = deg_to_rad(agent.dash_angular_turn_speed)

func _update(_delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed("dash") or (agent.leaf_meter <= 0) or agent.cutscene_mode):
		agent.check_airborne_state()
		agent.check_running_state()
		agent.check_idle_state()
	
	# Get new input vector depending on held Actions
	var new_input_direction: Vector2
	if (agent.cutscene_mode):
		new_input_direction = Vector2.ZERO
	else:
		new_input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if (new_input_direction != Vector2.ZERO):
		input_direction = new_input_direction
	
	if (input_direction != move_direction):
		# Turn toward the inputted direction
		turning = true
		move_direction = get_turned_move_direction()
	else:
		turning = false
	
	agent.velocity = move_direction * agent.dash_max_speed
	agent.flip_node.rotation = Vector2.RIGHT.angle_to(move_direction)
	
	agent.move_and_slide()

func _exit() -> void:

	agent.collision_shape_2d.shape = agent.collision_normal
	for ps: GPUParticles2D in agent.dash_particles.get_children(): # Enable Leaf Dash particles
		ps.emitting = false
	
	var new_look_direction: float = signf(agent.velocity.x)
	agent.flip_node.rotation = 0.0 # Reset rotation
	agent.look_direction = new_look_direction if (new_look_direction != 0.0) else agent.look_direction

# Returns the move direction Vector turned toward the input direction Vector by the angular turn speed
func get_turned_move_direction() -> Vector2:
	var angular_distance: float = move_direction.angle_to(input_direction)
	#print("Angular distance: ", angular_distance)
	
	var new_move_direction: Vector2
		
	if (abs(angular_distance) <= rad_angular_turn_speed):
		# Distance is less than one step of turning, so just set the move direction to the input direction
		new_move_direction = input_direction
	else:
		#if (abs(angular_distance) == (TAU / 2)): # If input is exactly in the other direction (PI)
			#new_move_direction = move_direction.rotated(rad_angular_turn_speed * signf(angular_distance) * -1.0)
		#else:
			new_move_direction = move_direction.rotated(rad_angular_turn_speed * signf(angular_distance))
	
	return new_move_direction
