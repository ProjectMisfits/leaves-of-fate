class_name MainMenu extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Signals that the game is started.
func _on_button_button_up() -> void:
	SceneManager.swap_scenes("res://src/maps/placeholder_test_level_01.tscn", null, self)
