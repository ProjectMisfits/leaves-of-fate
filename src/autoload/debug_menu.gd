extends Control
## A debug menu for the game.

## An array that will hold any debug labels we create.
var properties: Array

## A reference to the VBoxContainer the properties will exist in.
@onready var container: VBoxContainer = $PanelContainer/VBoxContainer

## The frame time. Used for variable update frequency.
const fps_ms: int = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

## Toggle the debug menu when the debug input is pressed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = not visible
		get_viewport().set_input_as_handled()

## Add a property to the debug menu.
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	if properties.has(id):
		@warning_ignore("integer_division")
		if Time.get_ticks_msec() / fps_ms % time_in_frames == 0:
			var target: Label = container.find_child(id, true, false) as Label
			target.text = id + ": " + str(value)
	else:
		var property: Label = Label.new()
		container.add_child(property)
		property.name = id
		property.text = id + ": " + str(value)
		properties.append(property)
	pass
