## The Player's airborne state and all relevant code for it.
extends LimboState

## Set the Player's animation.
func _enter() -> void:
	agent.animation_player.queue("player_fall_start")

## Move the Player & check if they may transition into another state.
func _update(delta: float) -> void:

	agent.check_dashing_state()
	#agent.check_piling_state()
	agent.check_running_state()
	agent.check_idle_state()
	
	agent.move_horizontal_air(delta)

##Exit state 
func _exit() -> void:
	agent.animation_player.queue("player_land")
