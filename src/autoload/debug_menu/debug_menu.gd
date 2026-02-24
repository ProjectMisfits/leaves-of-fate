extends Node
## A debug menu for the game.

## A reference to the debug menu canvas layer.
var debug_menu: CanvasLayer

## A reference to the debug properties debug panel.
var panel_debug_properties: DebugProperties

## A reference to the debug properties debug panel.
var panel_noclip: Noclip

## Whether the running build is a debug build.
var panel_enabled: bool = OS.has_feature("editor")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Disable input processing and skip creating the debug menu if this is an exported build.
	if not panel_enabled:
		set_process_input(false)
		return
	
	# Set up the debug menu.
	debug_menu = CanvasLayer.new()
	debug_menu.visible = false
	debug_menu.layer = 100
	add_child(debug_menu)
	
	var debug_vbox: VBoxContainer = VBoxContainer.new()
	debug_vbox.name = "DebugVBoxContainer"
	debug_vbox.size = Vector2(144.0, 86.0)
	debug_vbox.position = Vector2(50.0, 50.0)
	debug_vbox.theme = load("res://src/ui/debug_theme.tres")
	debug_menu.add_child(debug_vbox)
	
	panel_debug_properties = load("res://src/autoload/debug_menu/debug_properties.tscn").instantiate()
	debug_vbox.add_child(panel_debug_properties)
	
	panel_noclip = load("res://src/autoload/debug_menu/noclip.tscn").instantiate()
	debug_vbox.add_child(panel_noclip)

## Toggle the debug menu when the debug input is pressed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		debug_menu.visible = not debug_menu.visible
		get_viewport().set_input_as_handled()

## Add a debug property to the debug menu.
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	if panel_enabled:
		panel_debug_properties.add_debug_property(id, value, time_in_frames)
