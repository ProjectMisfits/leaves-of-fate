class_name HurtComponent extends Node2D
## A component that monitors for its parent getting hurt.

## A signal to indicate this component has registered a hurt.
signal hurt

## Whether the hurt has already occurred. Used to prevent repeat hurt triggers.
var is_hurt: bool = false

func _on_hurt_area_body_entered(_body: Node2D) -> void:
	if not is_hurt:
		hurt.emit()
		is_hurt = true
