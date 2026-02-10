@abstract class_name PlayerEnterTrigger extends Trigger
## Abstract base class for triggers that activate on player entry.


## Activate the trigger when the player enters the trigger area.
func _on_body_entered(_body: Node2D) -> void:
	trigger()
