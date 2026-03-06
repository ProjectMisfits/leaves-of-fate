## The Player's dashing state and all relevant code for it.
extends LimboState

var turning: bool = false						## If True, the Player is currently turning.
var move_direction: Vector2 = Vector2.RIGHT		## The direction the Player is moving in.
var input_direction: Vector2					## The user's inputted direction which the Player must turn toward.
var rad_angular_turn_speed: float				## The Player's turn speed in radians. Set using Dash database variables.

## An Area2D which checks whether the Player's normal collision shape would be overlapping a grate tile.
## The Player cannot end a Leaf Dash while overlapping with a grate tile.
@export var dash_grate_check_area: Area2D

## Set the Player's animation, particles, and change their collision mask to 
## let them pass through Leaf Mode platforms.
## Finally, set up move direction & radian turn speed.
func _enter() -> void:
	# Disable player interact and grab
	agent.grab_component.can_grab = false
	agent.interact_component.can_interact = false
	
	agent.animation_player.play("player_leaf_dash")

	agent.set_collision_mask_value(8,false)
	agent.set_collision_mask_value(10,true)
	for ps: GPUParticles2D in agent.dash_particles.get_children(): # Enable Leaf Dash particles
		if ps.name == "LeafBall":
			ps.show()
		if ps.name == "LeafExplosionParticle":
			ps.local_coords = false
			ps.restart()
		ps.emitting = true
	
	move_direction = get_input_direction()
	
	if (move_direction == Vector2.ZERO):
		move_direction = Vector2.RIGHT * signf(agent.look_direction) # Dash will go in the Player's look direction.
	
	input_direction = move_direction
	
	# Velocity should be at least the dash min speed, if not more.
	agent.velocity = move_direction * max(agent.velocity.length(), agent.dash_min_speed)
	
	rad_angular_turn_speed = deg_to_rad(agent.dash_angular_turn_speed)
	
	if (agent.meter_cooldown_timer.time_left > 0.0):	# If Leaf Meter cooldown timer was active
		agent.meter_cooldown_timer.stop()	# Stop timer; it will restart when exiting Dash state
	
	agent.dash_started.emit()

## Move & turn the Player. If the dash button is not held or the Player runs out of wind,
## check if they may transition into another state.
func _update(delta: float) -> void:
	# Check for state changes
	var is_overlapping_with_grates: bool = dash_grate_check_area.get_overlapping_bodies().size() > 0
	var is_unable_to_dash: bool = (not agent.input_processing) or agent.no_dash
	var is_dash_action_not_pressed: bool = not Input.is_action_pressed("dash")
	var is_leaf_meter_empty: bool = agent.leaf_meter <= 0.0
	
	if not is_overlapping_with_grates:
		if is_unable_to_dash or is_dash_action_not_pressed or (is_leaf_meter_empty and (not agent.infinite_dash)):
			agent.check_airborne_state()
			agent.check_running_state()
			agent.check_idle_state()
	
	# Get new input vector depending on held Actions
	var new_input_direction: Vector2
	if not agent.input_processing:
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
	
	var new_velocity_length: float = agent.velocity.length()
	
	if (new_velocity_length > agent.dash_max_speed):	# If current velocity is greater than max dash speed...
		# Apply friction to slow down until the Player reaches the max dash speed.
		new_velocity_length -= (agent.dash_speed_friction * delta)
		new_velocity_length = max(new_velocity_length, agent.dash_max_speed)
	else:
		# Increase speed & clamp by min & max dash speed.`
		new_velocity_length += (agent.dash_acceleration * delta)
		new_velocity_length = clampf(new_velocity_length, agent.dash_min_speed, agent.dash_max_speed)
	
	agent.velocity = new_velocity_length * move_direction
	agent.flip_node.rotation = Vector2.RIGHT.angle_to(move_direction)

## Revert the Player's animation, particles, and rotation back to their normal mode.
func _exit() -> void:
	agent.animation_player.play_backwards("player_leaf_dash")
	agent.set_collision_mask_value(8,true)
	agent.set_collision_mask_value(10,false)
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
	
	# Drain Leaf Meter by an amount after ending Leaf Dash.
	
	agent.set_leaf_meter(max(agent.leaf_meter - agent.meter_dash_end_drain, 0.0))
	
	# Queue Leaf Dash cooldown
	agent.dash_cooldown_queued = true
	
	# If airborne, add a burst of velocity
	if (not agent.is_on_floor()):
		agent.post_dash_mode = true
		agent.velocity *= agent.dash_end_velocity_multiplier
		
		if (agent.velocity.length() > agent.dash_end_max_velocity):
			agent.velocity = agent.velocity.normalized() * agent.dash_end_max_velocity

	# Re-enable player interact and grab
	agent.grab_component.can_grab = true
	agent.interact_component.can_interact = true

## Returns the move direction Vector turned toward the input direction Vector by the angular turn speed.
func get_turned_move_direction() -> Vector2:
	var angular_distance: float = move_direction.angle_to(input_direction)
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
