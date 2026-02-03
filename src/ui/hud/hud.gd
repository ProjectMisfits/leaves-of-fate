extends Control
class_name Hud

@onready var leaf_meter: TextureProgressBar = get_node("%LeafMeter")
@onready var total_lives: int = 3
@onready var player: Player = null
@onready var life1: TextureRect = get_node("%LifeLeaf1")
@onready var life2: TextureRect = get_node("%LifeLeaf2")
@onready var life3: TextureRect = get_node("%LifeLeaf3")

var respawn_speed: float = 0.5


func set_player(current_player: Player) -> void:
	player = current_player
	player.health_changed.connect(_set_player_health)
	player.leaf_meter_changed.connect(_set_leaf_meter)

# Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func _set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value

func _set_player_health(new_health: int) -> void:
	if new_health > total_lives:
		push_warning("New health is greater than number of health UI boxes.")
		return
	else:
		if new_health == 3:
			await get_tree().create_timer(respawn_speed).timeout
			create_tween().tween_property(life1, "modulate:a", 1.0, 0.25)
			create_tween().tween_property(life2, "modulate:a", 1.0, 0.25)
			create_tween().tween_property(life3, "modulate:a", 1.0, 0.25)
		elif new_health == 2:
			create_tween().tween_property(life3, "modulate:a", 0.0, 0.5)
		elif new_health == 1:
			create_tween().tween_property(life2, "modulate:a", 0.0, 0.5)
		elif new_health == 0:
			create_tween().tween_property(life1, "modulate:a", 0.0, 0.5)
