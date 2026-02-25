extends Control
class_name Hud
## A UI element for player health and leaf meter.

## A reference to the cooldown leaf node.
@onready var cooldown_leaf: TextureRect = %LifeLeaf1

## A reference to the leaf meter node.
@onready var leaf_meter: TextureProgressBar = %LeafMeter

## A reference to the player.
@onready var player: Player = null

func _ready() -> void:
	EventBus.player_knocked_out.connect(_on_player_knocked_out)
	EventBus.grabbed.connect(play_grabbed)
func _physics_process(_delta: float) -> void:
	# If Player cannot Leaf Dash, modify the Leaf Meter tint.
	if (player.no_dash):
		leaf_meter.tint_progress = Color.DIM_GRAY
		leaf_meter.tint_under = Color.BLACK
	else:
		leaf_meter.tint_under = Color(0.58, 0.48, 0.49)

## Called by gameplay to connect the exact Player instance to the Hud
func set_player(current_player: Player) -> void:
	player = current_player
	player.leaf_meter_changed.connect(_set_leaf_meter)
	player.dash_cooldown_timer_updated.connect(_set_cooldown_leaf)
	
	# When dash starts, make cooldown leaf disappear.
	player.dash_started.connect(_set_cooldown_leaf.bind(1.0, 1.0))

## Sets the cooldown leaf visual's color & opacity.
## Intended to be utilized by the Player's dash cooldown timer.
func _set_cooldown_leaf(max_value: float, new_value: float) -> void:
	var new_percent: float = (1 - (new_value / max_value))
	cooldown_leaf.modulate = Color(1, new_percent, new_percent, new_percent)

## Sets the leaf meter visual to the given value if it is within 0.0 - 100.0
func _set_leaf_meter(new_value: float) -> void:
	if (new_value < 0.0) or (new_value > 100.0):
		push_warning("Value parameter is not within 0.0 - 100.0.")
		return
	
	leaf_meter.value = new_value
	
	# If Player is able to Leaf Dash, update the Leaf Meter's tint
	if (not player.no_dash):
		if leaf_meter.value < 75:
			leaf_meter.tint_progress = Color(1, (leaf_meter.value / 75), (leaf_meter.value / 75), 1)
		else:
			leaf_meter.tint_progress = Color.WHITE

## Updates health in the HUD based on the players current health
func _on_player_knocked_out() -> void:
	create_tween().tween_property(%LifeLeaf1, "modulate:a", 0.0, 0.5)
	
func play_grabbed() -> void:
	%HudAnimator.play("bangle_animation")

func play_ungrabbed() -> void:
	%HudAnimator.play_backwards("bangle_animation")

## Reset HUD state.
func reset_hud() -> void:
	%LifeLeaf1.modulate.a = 1
