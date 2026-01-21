class_name Room extends Node2D
## A generic script for rooms that the player travels through.
## All rooms must extend from this class.

## An array containing all Doors in this Room that lead to other Rooms.
@export var doors: Array[Door]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
