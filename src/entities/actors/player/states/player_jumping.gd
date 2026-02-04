## The Player's jumping state and all relevant code for it.
extends LimboState

## Set the Player's animation & initiate a jump.
func _enter() -> void:
	#print("Player State Transition: to_jumping")
	agent.animation_player.play("player_idle")
	agent.jump()

## Move the Player & check if they may transition into another state.
## If the Player reached the peak of their jump, they may transition into the Airborne state.
func _update(delta: float) -> void:

	agent.check_dashing_state()
	agent.check_piling_state()
	
	if (agent.velocity.y >= 0.0):	# Can only transition into airborne once jump reaches peak
		agent.check_airborne_state()
	
	agent.move_horizontal_air(delta)
