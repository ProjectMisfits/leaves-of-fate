## The Player's idle state and all relevant code for it.
extends LimboState

## Set the Player's animation.
func _enter() -> void:
	#print("Player State Transition: to_idle")
	agent.animation_player.clear_queue()
	agent.animation_player.queue("player_idle")
	pass

## Check if the Player may transition into another state.
func _update(_delta: float) -> void:

	agent.check_dashing_state()
	#agent.check_piling_state()
	agent.check_jumping_state()
	agent.check_airborne_state()
	agent.check_running_state()
