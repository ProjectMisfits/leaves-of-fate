class_name ScreenTransition extends Control

## The animation player for the screen transition.
@onready var transition_animation_player: AnimationPlayer = %AnimationPlayer

## The transition animations supported by the ScreenTransition class.
enum transition_types {
	CIRCLE,
	FADE
}

## The current screen transition.
var screen_transition_type: String

## Set by start_transition if a transition should start at some position.
var input_position: Vector2 = Vector2.INF

## Start a screen transition.
func start_transition(transition_type: String, pos: Vector2 = Vector2.INF) -> void:
	if not transition_animation_player.has_animation(transition_type):
		push_error("ScreenTransition: Transition type '%s' not found." % transition_type)
		return
	
	# Set the screen transition type for use in the transition out animation.
	screen_transition_type = transition_type
	# Update the position for use by the animation.
	input_position = pos
	# Play the animation and wait for it to finish.
	transition_animation_player.play(screen_transition_type)
	await transition_animation_player.animation_finished

## Finish the current screen transition.
func finish_transition(pos: Vector2 = Vector2.INF) -> void:
	if not screen_transition_type:
		push_error("ScreenTransition: No screen transition type set or screen transition in progress.")
		return
	
	# Update the position for use by the animation.
	input_position = pos
	# Play the animation and wait for it to finish.
	transition_animation_player.play_backwards(screen_transition_type)
	await transition_animation_player.animation_finished;

## Handle the circle transition animation.
func _circle_transition() -> void:
	pass

## Sets up the the circle wipe positioning uniforms from the value of input_position.
func _circle_wipe_set_position() -> void:
	var mat: ShaderMaterial = $CanvasLayer/ColorRect.material
	if input_position == Vector2.INF:
		# If the irising position is not set, default to using the center of the screen for the transition.
		mat.set_shader_parameter("useCenterPosition", false)
	else:
		# Otherwise iris on the set position.
		mat.set_shader_parameter("useCenterPosition", true)
		mat.set_shader_parameter("centerPosition", get_canvas_transform() * input_position)

## Handle the fade transition animation.
func _fade_transition() -> void:
	pass
