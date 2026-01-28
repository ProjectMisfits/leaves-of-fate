extends Control
class_name PlayerUI

@onready var leaf_meter: ProgressBar = $VBoxContainer/LeafMeter
@onready var health_grid: GridContainer = $VBoxContainer/Health

# Sets the number of visible health rects to the given number.
func set_health(new_health: int) -> void:
	var health_nodes: Array[Node] = health_grid.get_children()
	
	if (new_health > health_nodes.size()):
		push_warning("New health is greater than number of health UI boxes.")
		return
	
	for node: Node in health_nodes:
		node.visible = false
	
	if (new_health <= 0):
		return	# Keep health visual at 0.
	else:
		for i: int in new_health:
			health_nodes[i].visible = true

# Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value
