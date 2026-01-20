## Jump math comes from the GDC Talk "Math for Game Programmers: Building a Better Jump
## Source: https://www.youtube.com/watch?v=hG9SzQxaCm8

extends CharacterBody2D

@export var database: JSON = null

### DATABASE VARIABLES ###
var gravity_multiplier: float
#var health: int
#var terminal_velocity: float

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
var fast_fall_gravity_multiplier: float
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

### STATE VARIABLES ###
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/Idle
@onready var running_state: LimboState = $LimboHSM/Running

### DYNAMIC VARIABLES ###
var look_direction: float = 1.0 # <0 is left, >=0 is right



func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

func _ready() -> void:
	initialize_state_machine()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_multiplier

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	move_and_slide()

# Adds state transitions & initializes state machine.
func initialize_state_machine() -> void:
	state_machine.add_transition(idle_state, running_state, "to_running")
	state_machine.add_transition(running_state, idle_state, "to_idle")
	
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

func check_idle_state() -> void:
	if is_on_floor():
		var velocity_is_zero: bool = (velocity == Vector2.ZERO)
		var x_input_is_zero: bool = (get_x_input() == 0.0)
		
		if velocity_is_zero and x_input_is_zero:
			state_machine.dispatch("to_idle")

func check_running_state() -> void:
	if is_on_floor():
		var x_input_not_zero: bool = (get_x_input() != 0.0)
		var x_velocity_not_zero: bool = (velocity.x != 0.0)
		
		if x_input_not_zero or x_velocity_not_zero:
			state_machine.dispatch("to_running")

# Get the input direction and handle the movement/deceleration.
func move_horizontal(acceleration: float, deceleration: float, turn_speed: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	var new_velocity: float = 0.0
	
	if (direction == 0.0): # No direction
		new_velocity = move_toward(velocity.x, 0, deceleration)
	else:
		var new_acceleration: float = 0.0
		
		if (signf(direction) == signf(velocity.x)): 	# Direction matches current velocity
			new_acceleration = direction * acceleration
		else: 											# Direction is opposite to current velocity
			new_acceleration = direction * turn_speed
		
		new_velocity = clampf(velocity.x + new_acceleration, -run_max_speed, run_max_speed)
		
	velocity.x = new_velocity
	look_direction = clampf(velocity.x, -1.0, 1.0)

func move_horizontal_ground() -> void:
	move_horizontal(ground_acceleration, ground_deceleration, ground_turn_speed)

# Returns the player's x-input value.
func get_x_input() -> float:
	return Input.get_axis("move_left", "move_right")

# Initializes all variables to values extracted from the entity's database.
func initialize_data(data: Dictionary) -> void:
		# Base Data #
		gravity_multiplier = data["gravity_multiplier"]
		run_max_speed = data["run_max_speed"]
		
		# Run #
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
		fast_fall_gravity_multiplier = data["fast_fall_gravity_multiplier"]
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
