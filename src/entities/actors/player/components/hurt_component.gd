class_name HurtComponent extends Node2D
## A component that allows an entity to be hurt.

## A signal to indicate this component has been hurt.
signal hurt

## Triggered when a hazard or enemy enters the hurt area.
func _on_hurt_area_body_entered(_body: Node2D) -> void:
	hurt.emit()
