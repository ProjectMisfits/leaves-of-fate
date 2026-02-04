## The Player's Leaf Pile state and all relevant code for it.
extends LimboState

## Set the Player's animation, collision shape, and change their collision mask to 
## let them pass through Leaf Mode platforms.
## Finally, reset their Y-velocity.
func _enter() -> void:
	#print("Player State Transition: to_pileing")
	agent.animation_player.play("player_leaf_pile")
	agent.set_collision_mask_value(8,false)
	agent.collision_shape_2d.shape = agent.collision_dash
	agent.velocity.y = 0.0

## Move the Player. If the dash button is not held or the Player runs out of wind,
## check if they may transition into another state.
func _update(delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed(&"dash") or (agent.leaf_meter <= 0) or agent.cutscene_mode):
		agent.check_airborne_state()
		agent.check_running_state()
		agent.check_idle_state()
	
	agent.velocity.y += agent.pile_gravity * delta
	agent.velocity.y = clampf(agent.velocity.y, -INF, agent.pile_terminal_velocity) # velocity cannot exceed terminal velocity
	
	if (agent.is_on_floor()):
		move_horizontal_pile_ground(delta)
	else:
		move_horizontal_pile_air(delta)

## Revert the Player's collision shape & mask.
func _exit() -> void:
	agent.set_collision_mask_value(8,true)
	agent.collision_shape_2d.shape = agent.collision_normal

## Calls move_horizontal with pile ground parameters.
func move_horizontal_pile_ground(delta: float) -> void:
	agent.move_horizontal(agent.pile_ground_acceleration, agent.pile_ground_deceleration, agent.pile_ground_turn_speed, delta)

## Calls move_horizontal with pile air parameters.
func move_horizontal_pile_air(delta: float) -> void:
	agent.move_horizontal(agent.pile_air_acceleration, agent.pile_air_deceleration, agent.pile_air_turn_speed, delta)
