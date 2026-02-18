class_name HurtComponent extends Node2D
## A component that allows an entity to be hurt.

## A signal to indicate this component has been hurt.
signal hurt

## Whether the hurt has already occurred. Used to prevent repeat hurt triggers.
var is_hurt: bool = false

## Triggered when a hazard or enemy enters the hurt area.
func _on_hurt_area_body_entered(_body: Node2D) -> void:
	if not is_hurt:
		hurt.emit()
		is_hurt = true
