## The Player's dashing state and all relevant code for it.
extends LimboState

var turning: bool = false						## If True, the Player is currently turning.
var move_direction: Vector2 = Vector2.RIGHT		## The direction the Player is moving in.
var input_direction: Vector2					## The user's inputted direction which the Player must turn toward.
var rad_angular_turn_speed: float				## The Player's turn speed in radians. Set using Dash database variables.

## Set the Player's animation, particles, and change their collision mask to 
## let them pass through Leaf Mode platforms.
## Finally, set up move direction & radian turn speed.
func _enter() -> void:
	#print("Player State Transition: to_dashing")
	agent.animation_player.play("player_leaf_dash")

	agent.set_collision_mask_value(8,false)
	for ps: GPUParticles2D in agent.dash_particles.get_children(): # Enable Leaf Dash particles
		
		print(agent.look_direction)
		ps.scale.x = -1 *agent.look_direction
		if ps.name == "LeafBall":
			ps.show()
		if ps.name == "LeafExplosionParticle":
			ps.local_coords = false
			ps.restart()
		
		ps.emitting = true
	
	move_direction = get_input_direction()
	rad_angular_turn_speed = deg_to_rad(agent.dash_angular_turn_speed)

## Move & turn the Player. If the dash button is not held or the Player runs out of wind,
## check if they may transition into another state.
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
		new_input_direction = get_input_direction()
	
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

## Revert the Player's animation, particles, and rotation back to their normal mode.
func _exit() -> void:
	agent.animation_player.play_backwards("player_leaf_dash")
	agent.set_collision_mask_value(8,true)
	for ps: GPUParticles2D in agent.dash_particles.get_children(): # Enable Leaf Dash particles
		ps.emitting = false
		ps.scale.x  = abs(ps.scale.x)
		if ps.name == "LeafBall":
			ps.hide()
		if ps.name == "LeafExplosionParticle":
			ps.local_coords = true
			ps.restart()
	
	var new_look_direction: float = signf(agent.velocity.x)
	agent.flip_node.rotation = 0.0 # Reset rotation
	agent.look_direction = new_look_direction if (new_look_direction != 0.0) else agent.look_direction
	
	agent.post_dash_mode = true

## Returns the move direction Vector turned toward the input direction Vector by the angular turn speed.
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

## Returns the input movement vector, normalized.
func get_input_direction() -> Vector2:
	var new_input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return new_input_direction.normalized()
