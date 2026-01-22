extends CharacterBody2D
class_name PlayerDash

var max_speed: float = 1200
var move_direction: Vector2
var input_direction: Vector2
var angular_turn_speed: float = 7.0
var turning: bool = false

var player_scene: Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	camera_2d.make_current()
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _physics_process(_delta: float) -> void:
	if (not Input.is_action_pressed("dash")):
		player_scene.end_dash(self)
	
	var new_input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if (new_input_direction != Vector2.ZERO):
		input_direction = new_input_direction
	
	if (input_direction != move_direction): # Turning to new direction
			turning = true
			var angular_distance: float = move_direction.angle_to(input_direction)
			print("Angular distance: ", rad_to_deg(angular_distance))
			if (abs(angular_distance) > deg_to_rad(angular_turn_speed)):
				move_direction = move_direction.rotated(deg_to_rad(angular_turn_speed) * signf(angular_distance))
			else:
				move_direction = input_direction
	
	sprite_2d.rotation = Vector2.RIGHT.angle_to(move_direction)
	velocity = move_direction * max_speed
	
	move_and_slide()
