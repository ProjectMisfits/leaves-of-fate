extends CharacterBody2D
class_name PlayerDash

@export var database: JSON = null

var max_speed: float
var angular_turn_speed: float

var turning: bool = false
var move_direction: Vector2
var input_direction: Vector2
var rad_angular_turn_speed: float

var player_scene: Player
var camera_2d: Camera2D = null

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var leaf_enter_audio: AudioStreamPlayer2D = $LeafEnterAudio


# Fetch database resource. If valid, initialize all variables.
func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

func _physics_process(_delta: float) -> void:
	# Check if Player stopped holding dash Action
	if (not Input.is_action_pressed("dash")):
		end_dash()
	
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
	#print("Angular distance: ", angular_distance)
	
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

# Set up all parameters for self, steal camera, & put Player entity into hibernation. Requires a valid Player scene reference.
func initialize_self() -> void:
	if(!leaf_enter_audio.playing):
		leaf_enter_audio.play()

	# Set database variables
	max_speed = player_scene.dash_max_speed
	angular_turn_speed = player_scene.dash_angular_turn_speed
	
	rad_angular_turn_speed = deg_to_rad(angular_turn_speed)
	
	global_position = player_scene.global_position
	move_direction = player_scene.velocity.normalized()
	
	# Steal camera
	camera_2d = player_scene.get_node("Camera2D")
	player_scene.remove_child(camera_2d)
	add_child(camera_2d)
	
	# Disable Player scene
	player_scene.visible = false
	player_scene.process_mode = Node.PROCESS_MODE_DISABLED

func end_dash() -> void:
	player_scene.end_dash(global_position, velocity)
	
	# Give camera back to player scene
	if camera_2d:
		remove_child(camera_2d)
		player_scene.add_child(camera_2d)
	
	queue_free()

func initialize_data(data: Dictionary) -> void:
	pass
