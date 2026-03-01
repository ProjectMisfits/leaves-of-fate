class_name InvisibleWall extends StaticBody2D

## An array containing the event flags that must be true for this invisible wall to exist.
@export var required_true_event_flags: Array[String]

## An array containing the event flags that must be false for this invisible wall to exist.
@export var required_false_event_flags: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ProcessingComponent.required_true_event_flags = self.required_true_event_flags
	$ProcessingComponent.required_false_event_flags = self.required_false_event_flags
