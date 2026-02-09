class_name ScreenTransition extends Control

## The animation player for the screen transition.
@onready var transition_animation_player: AnimationPlayer = $%AnimationPlayer

## The current screen transition.
var screen_transition_type: String

## Start a screen transition.
func start_transition(transition_type: String) -> void:
	if not transition_animation_player.has_animation(transition_type):
		push_warning("ScreenTransition: Transition type '%s' not found." % transition_type)
	screen_transition_type = transition_type
	transition_animation_player.play(screen_transition_type)

## Finish the current screen transition.
func finish_transition() -> void:
	if not screen_transition_type:
		push_warning("ScreenTransition: No screen transition type set or screen transition in progress.")
	transition_animation_player.play_backwards(screen_transition_type)
