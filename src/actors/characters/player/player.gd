## Jump math comes from the GDC Talk "Math for Game Programmers: Building a Better Jump
## Source: https://www.youtube.com/watch?v=hG9SzQxaCm8

extends CharacterBody2D
class_name Player

@export var database: JSON = null
@export var player_dash_scene: PackedScene = null

### DATABASE VARIABLES ###
var health: int
var terminal_velocity: float

## Run ##
var run_max_speed: float
var ground_acceleration: float
var ground_deceleration: float
var ground_turn_speed: float

var air_acceleration: float
var air_deceleration: float
var air_turn_speed: float

## Jump ##
var jump_height: float
var jump_time_to_peak: float
var fall_gravity_multiplier: float
var jump_coyote_time: float
var jump_buffer_time: float
var jump_corner_rounding_distance: float

## Leaf Dash ##
var meter_buildup_rate: float
var meter_drain_rate: float
var meter_dash_drain_rate: float
var meter_max_capacity: float

var dash_max_speed: float
var dash_initial_velocity: float
var dash_angular_turn_speed: float
var dash_deceleration: float
var dash_angular_turn_speed_deceleration: float
var meter_dash_deceleration_start: float

var dash_shimmy_max_speed: float
var dash_shimmy_acceleration: float
var dash_shimmy_deceleration: float
var dash_shimmy_turn_speed: float

### NODE REFERENCE VARIABLES ###
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var footstep_audio: AudioStreamPlayer2D = $FootstepsAudio
@onready var leaf_exit_audio: AudioStreamPlayer2D = $LeafExitAudio

## State Machine ##
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/Idle
@onready var running_state: LimboState = $LimboHSM/Running
@onready var jumping_state: LimboState = $LimboHSM/Jumping
@onready var airborne_state: LimboState = $LimboHSM/Airborne
@onready var dashing_state: LimboState = $LimboHSM/Dashing
@onready var shimmying_state: LimboState = $LimboHSM/Shimmying
@onready var interacting_state: LimboState = $LimboHSM/Interacting

### DYNAMIC VARIABLES ###
var current_health: int
var look_direction: float = 1.0 # <0 is left, >=0 is right
var jump_queued: bool = false
var leaf_meter: float = 100.0

var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var time_since_on_floor: float = 0.0
var time_since_jump_queued: float = 0.0

# Fetch database resource. If valid, initialize all variables.
func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

# Initializes state machine & computes jump variables for later use.
func _ready() -> void:
	initialize_state_machine()
	compute_jump_parameters()
	
	current_health = health

# Compute gravity, move_and_slide, & flip Player sprite based on look direction.
func _physics_process(delta: float) -> void:
	update_jump_queue(delta)
	
	velocity.y += compute_gravity() * delta
	velocity.y = clampf(velocity.y, -INF, terminal_velocity) # velocity cannot exceed terminal velocity
	
	sprite2d.flip_h = (look_direction < 0.0)	# Flip sprite to Player's look direction

	move_and_slide()
	
	# Update floor-dependent variables.
	# This MUST be done AFTER move_and_slide(), which updates is_on_floor().
	if is_on_floor():
		time_since_on_floor = 0.0
	else:
		time_since_on_floor += delta

# Adds state transitions & initializes state machine.
func initialize_state_machine() -> void:
	state_machine.add_transition(idle_state,running_state,"to_running")
	state_machine.add_transition(idle_state,jumping_state,"to_jumping")
	state_machine.add_transition(idle_state,airborne_state,"to_airborne")
	state_machine.add_transition(idle_state,dashing_state,"to_dashing")
	
	state_machine.add_transition(running_state,idle_state,"to_idle")
	state_machine.add_transition(running_state,jumping_state,"to_jumping")
	state_machine.add_transition(running_state,airborne_state,"to_airborne")
	state_machine.add_transition(running_state,dashing_state,"to_dashing")
	
	state_machine.add_transition(jumping_state,airborne_state,"to_airborne")
	state_machine.add_transition(jumping_state,dashing_state,"to_dashing")
	
	state_machine.add_transition(airborne_state,idle_state,"to_idle")
	state_machine.add_transition(airborne_state,running_state,"to_running")
	state_machine.add_transition(airborne_state,dashing_state,"to_dashing")
	
	state_machine.add_transition(dashing_state,idle_state,"to_idle")
	state_machine.add_transition(dashing_state,running_state,"to_running")
	state_machine.add_transition(dashing_state,airborne_state,"to_airborne")
	
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

# If the player is idling (not moving or trying to move), change to idle state.
func check_idle_state() -> void:
	if is_on_floor():
		var velocity_is_zero: bool = (velocity == Vector2.ZERO)
		var x_input_is_zero: bool = (get_x_input() == 0.0)
		
		if velocity_is_zero and x_input_is_zero:
			state_machine.dispatch("to_idle")

# If the player is moving on the ground, change to running state.
func check_running_state() -> void:
	if is_on_floor():
		var x_input_not_zero: bool = (get_x_input() != 0.0)
		var x_velocity_not_zero: bool = (velocity.x != 0.0)
		
		if x_input_not_zero or x_velocity_not_zero:
			state_machine.dispatch("to_running")

# If the player queued a jump & is on floor or within coyote time, change to jumping state.
func check_jumping_state() -> void:
	if jump_queued:
		var is_within_coyote_time: bool = (time_since_on_floor <= jump_coyote_time)
		if is_on_floor() or is_within_coyote_time:
			state_machine.dispatch("to_jumping")

# If the player is airborne AND the coyote timer has expired, change to airborne state.
func check_airborne_state() -> void:
	var is_coyote_timer_expired: bool = (time_since_on_floor > jump_coyote_time)
	if not is_on_floor() and is_coyote_timer_expired:
		state_machine.dispatch("to_airborne")

# If the player is trying to dash and leaf meter is not zero, change to dashing state.
func check_dashing_state() -> void:
	var is_leaf_meter_not_empty: bool = (leaf_meter > 0.0)
	
	if Input.is_action_just_pressed("dash") and is_leaf_meter_not_empty:
		state_machine.dispatch("to_dashing")

# Get the input direction and handle the movement/deceleration.
func move_horizontal(acceleration: float, deceleration: float, turn_speed: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	var new_velocity: float = 0.0
	
	if (direction == 0.0) and (state_machine.get_previous_active_state() != dashing_state): # No direction & did not exit Leaf Dash
		new_velocity = move_toward(velocity.x, 0, deceleration)

	else:
		var new_acceleration: float = 0.0
		
		if (signf(direction) == signf(velocity.x)): 	# Direction matches current velocity
			new_acceleration = direction * acceleration
		else: 											# Direction is opposite to current velocity
			new_acceleration = direction * turn_speed
		
		# If just exited Leaf Dash, limit velocity by dash max speed
		if (state_machine.get_previous_active_state() == dashing_state) and (abs(velocity.x) > run_max_speed):
			new_velocity = clampf(velocity.x + new_acceleration, -dash_max_speed, dash_max_speed)
		else:
			new_velocity = clampf(velocity.x + new_acceleration, -run_max_speed, run_max_speed)
		
		new_velocity = clampf(velocity.x + new_acceleration, -run_max_speed, run_max_speed)

		if(!footstep_audio.playing && is_on_floor_only()):
			footstep_audio.play()

	velocity.x = new_velocity
	
	# Pos/0 velocity = look right, neg velocity = look left
	var new_look_direction: float = signf(direction)
	look_direction = new_look_direction if (new_look_direction != 0.0) else look_direction

# Calls move_horizontal with ground parameters.
func move_horizontal_ground() -> void:
	move_horizontal(ground_acceleration, ground_deceleration, ground_turn_speed)

# Calls move_horizontal with air parameters.
func move_horizontal_air() -> void:
	move_horizontal(air_acceleration, air_deceleration, air_turn_speed)

# Returns the player's x-input value.
func get_x_input() -> float:
	return Input.get_axis("move_left", "move_right")

# Updates jump velocity & gravity variables
func compute_jump_parameters() -> void:
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak ** 2)) * -1.0

func compute_gravity() -> float:
	var new_velocity: float

	# Control variable jump height by checking is "jump" is being held
	if (state_machine.get_active_state() == jumping_state) and Input.is_action_pressed("jump"):
		new_velocity = jump_gravity
	else:
		new_velocity = jump_gravity * fall_gravity_multiplier
	
	return new_velocity

# Queues a new jump or updates/expires the timer since a jump was queued.
func update_jump_queue(delta: float) -> void:
	if jump_queued:
		time_since_jump_queued += delta
		print(time_since_jump_queued)
		if (time_since_jump_queued > jump_buffer_time):	# Check if jump has been queued for too long
			jump_queued = false							# Jump loses its queue
	elif Input.is_action_just_pressed("jump"):
		jump_queued = true
		time_since_jump_queued = 0.0

# Add y-velocity to make the player "jump".
func jump() -> void:
	jump_queued = false # Free jump queue
	velocity.y = jump_velocity
	time_since_on_floor = INF	# Prevent additional coyote jumps
	#print(jump_velocity)

# Instantiate player dash scene & hibernate self
func dash() -> void:
	# Create new player dash instance
	var new_player_dash: PlayerDash = player_dash_scene.instantiate()

	if not get_parent():
		push_error("failed to fetch parent reference.")
		return
	
	get_parent().add_child(new_player_dash)
	new_player_dash.player_scene = self
	new_player_dash.initialize_self()

# Called by PlayerDash to end a dash by re-enabling self.
func end_dash(new_position: Vector2, new_velocity: Vector2) -> void:
	
	if(!leaf_exit_audio.playing):
		leaf_exit_audio.play()
	
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	
	global_position = new_position
	velocity = new_velocity
	
	var new_look_direction: float = signf(velocity.x)
	look_direction = new_look_direction if (new_look_direction != 0.0) else look_direction

# Initializes all variables to values extracted from the entity's database.
func initialize_data(data: Dictionary) -> void:
		# Base Data #
		health = data["health"]
		terminal_velocity = data["terminal_velocity"]
		
		# Run #
		run_max_speed = data["run_max_speed"]
		ground_acceleration = data["ground_acceleration"]
		ground_deceleration = data["ground_deceleration"]
		ground_turn_speed = data["ground_turn_speed"]
		
		air_acceleration = data["air_acceleration"]
		air_deceleration = data["air_deceleration"]
		air_turn_speed = data["air_turn_speed"]
		
		# Jump #
		jump_height = data["jump_height"]
		jump_time_to_peak = data["jump_time_to_peak"]
		fall_gravity_multiplier = data["fall_gravity_multiplier"]
		jump_coyote_time = data["jump_coyote_time"]
		jump_buffer_time = data["jump_buffer_time"]
		jump_corner_rounding_distance = data["jump_corner_rounding_distance"]
		
		# Leaf Dash #
		meter_buildup_rate = data["meter_buildup_rate"]
		meter_drain_rate = data["meter_drain_rate"]
		meter_dash_drain_rate = data["meter_dash_drain_rate"]
		meter_max_capacity = data["meter_max_capacity"]
		
		dash_max_speed = data["dash_max_speed"]
		dash_initial_velocity = data["dash_initial_velocity"]
		dash_angular_turn_speed = data["dash_angular_turn_speed"]
		dash_deceleration = data["dash_deceleration"]
		dash_angular_turn_speed_deceleration = data["dash_angular_turn_speed_deceleration"]
		meter_dash_deceleration_start = data["meter_dash_deceleration_start"]
		
		dash_shimmy_max_speed = data["dash_shimmy_max_speed"]
		dash_shimmy_acceleration = data["dash_shimmy_acceleration"]
		dash_shimmy_deceleration = data["dash_shimmy_deceleration"]
		dash_shimmy_turn_speed = data["dash_shimmy_turn_speed"]
