class_name SettingsMenu extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("%ControlsButton").grab_focus.call_deferred()
