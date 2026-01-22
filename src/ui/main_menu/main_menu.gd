class_name MainMenu extends Control
## The main menu for the game.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Signals that the game is started.
func _on_button_button_up() -> void:
	SceneManager.swap_scenes("res://src/gameplay/gameplay.tscn", null, self)
