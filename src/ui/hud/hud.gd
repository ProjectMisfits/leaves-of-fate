extends Control
class_name Hud

@onready var leaf_meter: TextureProgressBar = get_node("%LeafMeter")
@onready var total_lives: int = 3
@onready var player: Player = null

var respawn_speed: float = 0.5

## Called by gameplay to connect the exact Player instance to the Hud
func set_player(current_player: Player) -> void:
	player = current_player
	player.health_changed.connect(_set_player_health)
	player.leaf_meter_changed.connect(_set_leaf_meter)

## Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func _set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value

## Updates health in the HUD based on the players current health
func _set_player_health(new_health: int) -> void:
	if new_health > total_lives:
		push_warning("New health is greater than number of health UI boxes.")
		return
	else:
		if new_health:
			await get_tree().create_timer(respawn_speed).timeout
			create_tween().tween_property(%LifeLeaf1, "modulate:a", 1.0, 0.5)
		else:
			create_tween().tween_property(%LifeLeaf1, "modulate:a", 0.0, 0.5)
		#if new_health == 3: # respawns all lives when player health is max 
			#await get_tree().create_timer(respawn_speed).timeout
			#create_tween().tween_property(%LifeLeaf1, "modulate:a", 1.0, 0.25)
			#create_tween().tween_property(%LifeLeaf2, "modulate:a", 1.0, 0.25)
			#create_tween().tween_property(%LifeLeaf3, "modulate:a", 1.0, 0.25)
		#elif new_health == 2: # removes right most leaf when looses first life
			#create_tween().tween_property(%LifeLeaf3, "modulate:a", 0.0, 0.5)
		#elif new_health == 1: # removes middle leaf when loses middle life
			#create_tween().tween_property(%LifeLeaf2, "modulate:a", 0.0, 0.5)
		#elif new_health == 0: # removes left most leaf when looses last life
			#create_tween().tween_property(%LifeLeaf1, "modulate:a", 0.0, 0.5)
