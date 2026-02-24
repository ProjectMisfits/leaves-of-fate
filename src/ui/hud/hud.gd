extends Control
class_name Hud
## A UI element for player health and leaf meter.

## A reference to the leaf meter node.
@onready var leaf_meter: TextureProgressBar = %LeafMeter

## A reference to the player.
@onready var player: Player = null

func _ready() -> void:
	EventBus.player_knocked_out.connect(_on_player_knocked_out)

## Called by gameplay to connect the exact Player instance to the Hud
func set_player(current_player: Player) -> void:
	player = current_player
	player.leaf_meter_changed.connect(_set_leaf_meter)

## Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func _set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value
	
	if leaf_meter.value < 75:
		leaf_meter.tint_progress = Color(1, (leaf_meter.value / 75), (leaf_meter.value / 75), 1)
	else:
		leaf_meter.tint_progress = Color.WHITE

## Updates health in the HUD based on the players current health
func _on_player_knocked_out() -> void:
	create_tween().tween_property(%LifeLeaf1, "modulate:a", 0.0, 0.5)

## Reset HUD state.
func reset_hud() -> void:
	%LifeLeaf1.modulate.a = 1
