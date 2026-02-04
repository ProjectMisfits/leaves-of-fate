## The Player's running state and all relevant code for it.
extends LimboState

## Set the Player's animation.
func _enter() -> void:
	#print("Player State Transition: to_running")
	agent.animation_player.play("player_walk_cycle")
	pass

## Move the Player & check if they may transition into another state.
func _update(delta: float) -> void:

	agent.check_dashing_state()
	agent.check_piling_state()
	agent.check_jumping_state()
	agent.check_airborne_state()
	agent.check_idle_state()
	
	agent.move_horizontal_ground(delta)
