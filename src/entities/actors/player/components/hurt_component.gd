class_name HurtComponent extends Node2D
## A component that monitors for its parent getting hurt.

## A signal to indicate this component has registered a hurt.
signal hurt

func _on_hurt_area_body_entered(_body: Node2D) -> void:
	hurt.emit()
