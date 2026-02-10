class_name MovingPlatform extends Path2D
## A moving platform that follows a 2d path.

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
@export var easing: float = -1.5

#Controls the current speed at which the platform goes along the path
var cur_closed_loop_speed: float
#Controls the speed scale of an animation for an open looped platform
var cur_open_loop_speed_scale:float 

#Variable controlling the object that follows
@onready var path: PathFollow2D = $PathFollow2D
#animation player for it
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_closed_loop_speed = closed_loop_speed
	cur_open_loop_speed_scale = open_loop_speed_scale
	
	initialize_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	progress_path()
	pass

func progress_path()->void:
	if closed_loop:
		for path_child in self.get_children():
			if path_child.get_class() == "PathFollow2D":
				path_child.progress += cur_closed_loop_speed

func initialize_animation()->void:
	if not closed_loop:
		animation_player.get_animation("move_base_animation").track_set_key_transition(0,0,easing)
		animation_player.play("move_base_animation")
		animation_player.speed_scale = cur_open_loop_speed_scale

func set_closed_speed(new_speed: float)->void:
	cur_closed_loop_speed = new_speed;
	
func set_open_speed(_new_speed: float)->void:
	animation_player.speed_scale = cur_open_loop_speed_scale

## Stop the platform's movement when it is grabbed.
func _grab()->void:
	if closed_loop:
		cur_closed_loop_speed = 0
	else:
		animation_player.speed_scale = 0

## Resume the platform's movement when it is ungrabbed. 
func _ungrab() -> void:
	if closed_loop:
		cur_closed_loop_speed = closed_loop_speed
	else:
		animation_player.speed_scale = cur_open_loop_speed_scale
