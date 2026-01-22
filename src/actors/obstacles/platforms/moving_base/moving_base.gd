extends Node

class_name Moving_Platform_base

#Controls if the platform should loop through its path
@export var  loop: bool = true
#Controls the speed at which the platform goes along the path
@export var speed: float = 2.0
#Controls the speed scale of an animation for an open looped platform
@export  var speed_scale:float = 1.0
#Controls the easing of the platform going back and forth 
@export var easing: float = -1.55
#Variable controlling the path
@onready var path: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.get_animation("move_base_animation").track_set_key_transition(0,0,easing)
	
	if not loop:
		animation_player.play("move_base_animation")
		animation_player.speed_scale = speed_scale
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loop:
		path.progress += speed
	pass
