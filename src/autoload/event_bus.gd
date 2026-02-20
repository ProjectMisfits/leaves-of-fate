## Global event bus which allows any script to connect to & emit its signals.
## Also handles global actions like "quit" and pausing.
extends Node

# Create global signals by defining them here.
#Signal to interupt dialouge moments
signal interrupt_dialogue(delay: String)
#Signal that a camera has changed
signal camera_change
#Signal to change beep speech frequency
signal frequency_change(new_freqeuncy : int)

## Signal triggered when the player is knocked out.
signal player_knocked_out

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
	elif event.is_action_pressed("ui_text_backspace"):
		if SceneManager.current_scene.name == "Gameplay":
			var gameplay_node: Node = SceneManager.current_scene
			
			if gameplay_node.pause_menu.get_parent() != null:
				if gameplay_node.settings_menu.get_parent() != null:
					if gameplay_node.controls_menu.get_parent() != null:
						gameplay_node.close_controls_menu()
						
					elif gameplay_node.volume_menu.get_parent() != null:
						gameplay_node.close_volume_menu()
					else:
						gameplay_node.close_settings_menu()
		elif SceneManager.current_scene.name == "MainMenu":
			var main_menu_node: MainMenu = SceneManager.current_scene
			
			if main_menu_node.settings_menu.get_parent() != null:
				
				if main_menu_node.controls_menu.get_parent() != null:
					main_menu_node.close_controls_menu()
				elif main_menu_node.volume_menu.get_parent() != null:
					main_menu_node.close_volume_menu()
				else:
					main_menu_node.close_settings_menu()
			elif main_menu_node.controls_menu.get_parent() != null:
				main_menu_node.close_controls_menu()
	elif event.is_action_pressed("game_reset"):
		# When this keybind is pressed:
		# - go back to the main menu
		SceneManager.swap_scenes("res://src/ui/main_menu/main_menu.tscn", null, SceneManager.current_scene)
		# - reset all event flags to their defaults
		EventFlags._reset_all_flags()
		# - anything else needed to reset the game
	
