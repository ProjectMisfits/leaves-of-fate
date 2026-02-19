class_name ScreenTransition extends Control

## The animation player for the screen transition.
@onready var transition_animation_player: AnimationPlayer = %AnimationPlayer

## The current screen transition.
var screen_transition_type: String

## Set by start_transition if a transition should start at some position.
var input_position: Vector2 = Vector2.INF;

## Sets up the the circle wipe positioning uniforms from the value of input_position.
func _circle_wipe_set_position() -> void:
	var mat: ShaderMaterial = $CanvasLayer/ColorRect.material
	if input_position == Vector2.INF:
		print('Centering!')
		mat.set_shader_parameter("useCenterPosition", false)
	else:
		mat.set_shader_parameter("useCenterPosition", true)
		mat.set_shader_parameter("centerPosition", get_canvas_transform() * input_position)

func _update_pos(pos: Vector2) -> void:
	assert(pos is Vector2, "ScreenTransition: start_transition provided with invalid pos value! Expected Vector2")
	input_position = pos
	# TODO(jadon): This is a bit of a hack.
	# If we decide we want a bunch of different kinds of wipes, it might be better
	# to make the AnimationPlayer call it from within the track instead of just always running it.
	if screen_transition_type == "circle":
		_circle_wipe_set_position()

## Start a screen transition.
func start_transition(transition_type: String, pos: Vector2 = Vector2.INF) -> void:
	$CanvasLayer.show();
	if not transition_animation_player.has_animation(transition_type):
		push_warning("ScreenTransition: Transition type '%s' not found." % transition_type)
	screen_transition_type = transition_type
	_update_pos(pos)
	transition_animation_player.play(screen_transition_type)
	await transition_animation_player.animation_finished

## Finish the current screen transition.
func finish_transition(pos = null) -> void:
	if not screen_transition_type:
		push_warning("ScreenTransition: No screen transition type set or screen transition in progress.")
	_update_pos(pos)
	transition_animation_player.play_backwards(screen_transition_type)
	await transition_animation_player.animation_finished;
	$CanvasLayer.hide();
