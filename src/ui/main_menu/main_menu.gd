class_name MainMenu extends Control
## The main menu for the game.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"CanvasLayer/MainSelectionsContainer/PlayButton".grab_focus.call_deferred()

# Signals that the game is started.
func _on_play_button_button_up() -> void:
	SceneManager.swap_scenes("res://src/gameplay/gameplay.tscn", null, self)

func _on_settings_button_up() -> void:
	SceneManager.swap_scenes("res://src/ui/settings_menu/settings_menu.tscn", null, self)

func _on_return_label_button_up() -> void:
	SceneManager.swap_scenes("res://src/ui/settings_menu/controls_menu/controls_menu.tscn", null, self)

func _on_exit_button_up() -> void:
	get_tree().quit()
