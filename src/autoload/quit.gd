extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Initiate quitting the game when the quit keybind is pressed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		# Propagate a notification that the program is quitting so that all nodes prepare for shutdown.
		# By doing this first, we allow any custom actions, such as saving, confirming the quit, or debugging to occur.
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		# Actually quit.
		get_tree().quit()
	elif event.is_action_pressed("pause"):
		if SceneManager.current_scene.name == "Gameplay":
			SceneManager.current_scene.toggle_pause()
