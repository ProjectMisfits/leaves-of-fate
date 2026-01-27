extends CanvasLayer
## A debug menu layer for the game.

## A reference to the debug properties debug panel.
@onready var panel_debug_properties: DebugProperties = $VBoxContainer/DebugProperties

## A reference to the debug properties debug panel.
@onready var panel_noclip: Noclip = $VBoxContainer/Noclip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

## Toggle the debug menu when the debug input is pressed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = not visible
		get_viewport().set_input_as_handled()

# Pass along the request to add a debug property to the debug properties panel.
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	panel_debug_properties.add_debug_property(id, value, time_in_frames)
