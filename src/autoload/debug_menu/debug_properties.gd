class_name DebugProperties extends PanelContainer
## A debug panel for the game that contains trackable properties.

## An array that will hold any debug labels we create.
var properties: Array

## A reference to the VBoxContainer the properties exist in.
@onready var container: VBoxContainer = $VBoxContainer/VBoxContainer

## The frame time. Used for variable update frequency.
const fps_ms: int = 16

# Called once on each physics tick.
func _physics_process(_delta: float) -> void:
	self.add_debug_property("Seconds Elapsed", snapped(Time.get_ticks_msec() / 1000.0, 0.1), 0)

## Add a property to the debug menu.
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	if properties.has(id):
		@warning_ignore("integer_division")
		if time_in_frames == 0 or Time.get_ticks_msec() / fps_ms % time_in_frames == 0:
			var target: Label = container.find_child(id, true, false) as Label
			target.text = id + ": " + str(value)
	else:
		var property: Label = Label.new()
		container.add_child(property)
		property.name = id
		property.text = id + ": " + str(value)
		properties.append(id)
