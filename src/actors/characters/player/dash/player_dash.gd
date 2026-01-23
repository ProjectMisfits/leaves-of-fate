extends CharacterBody2D
class_name PlayerDash

@export var database: JSON = null

### DATABASE VARIABLES ###
var dash_max_speed: float
var dash_initial_velocity: float
var dash_angular_turn_speed: float
var dash_deceleration: float
var dash_angular_turn_speed_deceleration: float
var meter_dash_deceleration_start: float

### DYNAMIC VARIABLES ###
var turning: bool = false
var move_direction: Vector2 = Vector2.RIGHT
var input_direction: Vector2
var rad_angular_turn_speed: float

var player_scene: Player
var camera_2d: Camera2D = null

## NODE REFERENCES ##
@onready var flip_node: Node2D = $FlipNode



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
	
	velocity = move_direction * dash_max_speed
	flip_node.rotation = Vector2.RIGHT.angle_to(move_direction)
	
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
func control_player(new_player_scene: Player) -> void:
	if (new_player_scene == null):
		push_error("Player parameter equals 'null'.")
	
	player_scene = new_player_scene
	
	# Take over Player's position & move direction
	global_position = player_scene.global_position
	move_direction = player_scene.velocity.normalized()
	
	# Steal camera
	camera_2d = player_scene.get_node("Camera2D")
	if (camera_2d != null):
		player_scene.remove_child(camera_2d)
		add_child(camera_2d)
	
	player_scene.set_disabled(true)

func end_dash() -> void:
	if (player_scene == null):
		push_error("Player scene variable equals 'null'.")
		return
	else:
		# Give camera back to player scene
		if camera_2d:
			remove_child(camera_2d)
			player_scene.add_child(camera_2d)
		
		player_scene.global_position = global_position
		player_scene.velocity = velocity
		
		var new_look_direction: float = signf(player_scene.velocity.x)
		player_scene.look_direction = new_look_direction if (new_look_direction != 0.0) else player_scene.look_direction
		
		player_scene.set_disabled(false)
	
	queue_free()

# Initializes all variables to values extracted from the entity's database.
func initialize_data(data: Dictionary) -> void:
	dash_max_speed = data["dash_max_speed"]
	dash_initial_velocity = data["dash_initial_velocity"]
	dash_angular_turn_speed = data["dash_angular_turn_speed"]
	dash_deceleration = data["dash_deceleration"]
	dash_angular_turn_speed_deceleration = data["dash_angular_turn_speed_deceleration"]
	meter_dash_deceleration_start = data["meter_dash_deceleration_start"]
	
	rad_angular_turn_speed = deg_to_rad(dash_angular_turn_speed)
