extends CharacterBody2D
class_name PlayerDash

var max_speed: float = 1200
var move_direction: Vector2
var input_direction: Vector2
var angular_turn_speed: float = 7.0
var turning: bool = false

var rad_angular_turn_speed: float

var player_scene: Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	camera_2d.make_current()
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	rad_angular_turn_speed = deg_to_rad(angular_turn_speed)

func _physics_process(_delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed("dash")):
		player_scene.end_dash(self)
	
	# Get new input vector depending on held Actions
	var new_input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if (new_input_direction != Vector2.ZERO):
		input_direction = new_input_direction
	
	if (input_direction != move_direction):
		# Turn toward the inputted direction
		turning = true
		move_direction = get_turned_move_direction()
	else:
		turning = false
	
	velocity = move_direction * max_speed
	sprite_2d.rotation = Vector2.RIGHT.angle_to(move_direction)
	
	move_and_slide()

# Returns the move direction Vector turned toward the input direction Vector by the angular turn speed
func get_turned_move_direction() -> Vector2:
	var angular_distance: float = move_direction.angle_to(input_direction)
	print("Angular distance: ", angular_distance)
	
	var new_move_direction: Vector2
		
	if (abs(angular_distance) <= rad_angular_turn_speed):
		# Distance is less than one step of turning, so just set the move direction to the input direction
		new_move_direction = input_direction
	else:
		#if (abs(angular_distance) == (TAU / 2)): # If input is exactly in the other direction (PI)
			#new_move_direction = move_direction.rotated(rad_angular_turn_speed * signf(angular_distance) * -1.0)
		#else:
			new_move_direction = move_direction.rotated(rad_angular_turn_speed * signf(angular_distance))
	
	return new_move_direction
