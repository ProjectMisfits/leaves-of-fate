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

## An override to enable the debug menu in exported builds if desired.
@export var panel_enabled_override: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the debug menu if it should be enabled.
	if panel_enabled or panel_enabled_override:
		_init_debug_menu()
	else:
		# Otherwise disable input processing since this is an exported build.
		# Will make this script's methods into dummies that don't do anything
		# when called by other game code.
		set_process_input(false)

## Initialize the debug menu.
func _init_debug_menu() -> void:
	# Set up the debug menu.
	debug_menu = load("res://src/autoload/debug_menu/debug_menu_scene.tscn").instantiate()
	panel_debug_properties = debug_menu.get_node("%DebugProperties")
	panel_noclip = debug_menu.get_node("%Noclip")
	add_child(debug_menu)

## Toggle the debug menu when the debug input is pressed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		debug_menu.visible = not debug_menu.visible
		get_viewport().set_input_as_handled()

## Add a debug property to the debug menu.
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	if panel_enabled or panel_enabled_override:
		panel_debug_properties.add_debug_property(id, value, time_in_frames)
