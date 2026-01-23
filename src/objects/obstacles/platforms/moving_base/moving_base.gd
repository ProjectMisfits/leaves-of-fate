extends Node

class_name Moving_Platform_base
#How to make a path:
#After placing the object in the scene you can create a path by selecting points on the top hotbar.
#The object will naturally follow that path at the rate you set



#Controls if the platform is a closed loop
#Closed loop: The platform naturally returns to its starting position, i.e in a circle
#Open loop: The platform wil back track from the end point to return to the start. i.e move back and forth
@export var  closed_loop: bool = true
#Controls the speed at which the platform goes along the path
@export var closed_loop_speed: float = 2.0
#Controls the speed scale of an animation for an open looped platform
@export  var open_loop_speed_scale:float = 1.0
#Controls the easing of the platform going back and forth 
@export var easing: float = -1.55


#Variable controlling the object that follows
@onready var path: PathFollow2D = $PathFollow2D
#animation player for it
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not closed_loop:
		animation_player.get_animation("move_base_animation").track_set_key_transition(0,0,easing)
		animation_player.play("move_base_animation")
		animation_player.speed_scale = open_loop_speed_scale
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if closed_loop:
		path.progress += closed_loop_speed
	pass
