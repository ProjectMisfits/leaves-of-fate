class_name Decor extends Node2D
## A base decorative texture for environmental objects.

## Should this decor's texture render in front of doors?
@export var in_front_of_door: bool = false
## Should this decor's texture render in front of the player? Overrides in_front_of_door if enabled.
@export var in_front_of_player: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Use the export properties to set this decor's z-index for rendering.
	if in_front_of_player:
		z_index = 5
		
	elif in_front_of_door:
		z_index = 3
	else:
		z_index = 1
		modulate = Color(0.521, 0.521, 0.521, 1.0)
