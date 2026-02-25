## The Player's cutscene state and all relevant code for it.
extends LimboState

## The axis of the current movement. 0 if not moving.
var move_axis: float = 0

## The time remaining on movement duration.
var target_x: float

## Set the Player's animation.
func _enter() -> void:
	agent.disable_player_input()
	agent.velocity = Vector2(0.0, 0.0)
	target_x = agent.global_position.x
	agent.animation_player.queue("player_idle")

## Handle physics in cutscenes as if the player were an NPC.
func _update(_delta: float) -> void:
	# Check whether we're at our target x. If so, stop moving.
	if agent.global_position.x != target_x:
		# If the NPC is at or beyond its target x relative to the direction it's moving,
		# reset its velocity and just place it at its target location.
		if (agent.global_position.x - target_x) * move_axis > 0:
			agent.velocity = Vector2.ZERO
			move_axis = 0
			agent.global_position.x = target_x
			agent.animation_player.play("player_idle")
			CutsceneManager.npc_finished_moving.emit()

## Exit cutscene state.
func _exit() -> void:
	agent.enable_player_input()

## Move Fenn based on the given parameters.
## move_direction: one of "left" or "right"
func move(destination_global_x: float, move_speed: float, animate_walk: bool = true, moonwalk: bool = false) -> void:
	# Determine which direction the NPC needs to move
	move_axis = -1.0 if destination_global_x < agent.global_position.x else 1.0
	# Set the direction to face based on the direction to move and moonwalk
	if not moonwalk:
		set_look(move_axis)
	else:
		set_look(move_axis * -1.0)
	
	# Set NPC velocity
	target_x = destination_global_x
	agent.velocity = Vector2(move_speed * move_axis, 0)
	# Set NPC move animation
	if animate_walk:
		agent.animation_player.play("player_walk_cycle")

## Set Fenn to look in the given direction.
func set_look(face_axis: float) -> void:
	agent.look_direction = face_axis
