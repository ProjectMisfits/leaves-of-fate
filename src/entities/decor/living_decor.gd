class_name LivingDecor extends Decor
## A living decorative texture which bounces from side to side.

@export var sway_sec: float = 3.0			## How long (in seconds) it takes to sway to one side.
@export var sway_max_angle: float = 10.0	## How far (in degrees) the decor will sway to one side.
@export var bounce_min_scale: float = 0.95 	## The Y-scale's minimum value during a bounce.
@export var bounce_max_scale: float = 1.05 	## The Y-scale's final value at the peak of the decor's bounce.

var sway_tween: Tween	## Reference to the sway tween.
var bounce_tween: Tween	## Reference to the bounce tween.

@export var tween_node: Node2D	## Reference to the Node to tween.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	var rand_start: float = randf()	# Used to start tweens midway to avoid all instances from syncing with each other.
	
	# Initialize the sway tween.
	tween_node.rotation_degrees = -sway_max_angle	# Set sway rotation to one side to start.
	
	if sway_tween:
		sway_tween.kill()
	
	sway_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sway_tween.tween_property(tween_node, "rotation_degrees", sway_max_angle, sway_sec)
	sway_tween.tween_property(tween_node, "rotation_degrees", -sway_max_angle, sway_sec)
	sway_tween.set_loops()	# Make tween run indefinitely.
	sway_tween.custom_step(rand_start * (sway_sec * 2))
	
	# Initialize the bounce tween.
	tween_node.scale.y = bounce_max_scale	# Set bounce scale to the max to start.
	
	if bounce_tween:
		bounce_tween.kill()
	
	bounce_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bounce_tween.tween_property(tween_node, "scale", Vector2(scale.x, bounce_min_scale), sway_sec / 2)
	bounce_tween. tween_property(tween_node, "scale", Vector2(scale.x, bounce_max_scale), sway_sec / 2)
	bounce_tween.set_loops()	# Make tween run indefinitely.
	bounce_tween.custom_step(rand_start * (sway_sec * 2))
