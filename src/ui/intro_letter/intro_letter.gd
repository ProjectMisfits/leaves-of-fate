extends Control

## Whether the continue prompt is visible.
var continue_prompt_visible: bool = false

## Handle input
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		if not continue_prompt_visible:
			_show_continue_prompt()
		else:
			_progress_to_gameplay()

## Show the continue prompt
func _show_continue_prompt() -> void:
	var prompt_tween: Tween = create_tween()
	prompt_tween.tween_property($TextureRect/Control, "modulate:a", 1.0, 0.5)
	prompt_tween.tween_callback(_mark_continue_prompt_as_visible)

## Mark the continue prompt as visible
func _mark_continue_prompt_as_visible() -> void:
	continue_prompt_visible = true
	
## Progress to gameplay
func _progress_to_gameplay() -> void:
	SceneManager.swap_scenes_with_transition("res://src/gameplay/gameplay.tscn", null, self)
