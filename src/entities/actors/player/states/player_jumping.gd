## The Player's jumping state and all relevant code for it.
extends LimboState

## Set the Player's animation & initiate a jump.
func _enter() -> void:
	#print("Player State Transition: to_jumping")
	agent.animation_player.queue("player_jump_start")
	jump()

## Move the Player & check if they may transition into another state.
## If the Player reached the peak of their jump, they may transition into the Airborne state.
func _update(delta: float) -> void:

	agent.check_dashing_state()
	agent.check_piling_state()
	
	if (agent.velocity.y >= 0.0):	# Can only transition into airborne once jump reaches peak
		agent.check_airborne_state()
	
	agent.move_horizontal_air(delta)

## Add y-velocity to make the player "jump".
func jump() -> void:
	agent.jump_queued = false # Free jump queue
	agent.velocity.y = agent.jump_velocity
	agent.time_since_on_floor = INF	# Prevent additional coyote jumps
