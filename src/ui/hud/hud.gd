extends Control
class_name Hud

@onready var leaf_meter: TextureProgressBar = get_node("%LeafMeter")
@onready var total_lives: int = 3

func _ready() -> void:
	set_player_health(2)

# Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value

func set_player_health(new_health: int) -> void:
	var life_nodes: Array[Node] = [get_node("%LifeLeaf3"), get_node("%LifeLeaf2"), get_node("%LifeLeaf1")]
	
	if new_health > total_lives:
		push_warning("New health is greater than number of health UI boxes.")
		return
	elif new_health < total_lives: 
		for i: int in (total_lives - new_health):
			# life_nodes[i].modulate.a = 0
			create_tween().tween_property(life_nodes[i], "modulate:a", 0, 0.5)
	else:
		for n: Node in life_nodes:
			n.modulate.a = 100
