## Jump math comes from the GDC Talk "Math for Game Programmers: Building a Better Jump
## Source: https://www.youtube.com/watch?v=hG9SzQxaCm8

extends CharacterBody2D
class_name Player

### RESOURCES ###
@export var database: JSON = null
@export var collision_normal: CapsuleShape2D = null
@export var collision_dash: CircleShape2D = null

### DATABASE VARIABLES ###
var health: int
var terminal_velocity: float

## Run ##
var run_max_speed: float
var ground_acceleration: float
var ground_deceleration: float
var ground_turn_speed: float
var ground_friction: float

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

## Leaf Dash Mode ##
var meter_buildup_rate: float
var meter_drain_rate: float
var meter_dash_drain_rate: float
var meter_pile_drain_rate: float

var dash_max_speed: float
var dash_angular_turn_speed: float
var dash_deceleration: float
var dash_angular_turn_speed_deceleration: float
var meter_dash_deceleration_start: float

## Leaf Pile Mode ##
var pile_gravity: float
var pile_terminal_velocity: float

var pile_max_speed_ground: float
var pile_ground_acceleration: float
var pile_ground_deceleration: float
var pile_ground_turn_speed: float
var pile_ground_friction: float

var pile_max_speed_air: float
var pile_air_acceleration: float
var pile_air_deceleration: float
var pile_air_turn_speed: float

var fun_value: int	# Every copy of Project Misfits is personalized

## Node references + State Machine ##
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# flip_node scale changes depending on Player's look direction; all children will be flipped.
@onready var flip_node: Node2D = $FlipNode
@onready var dash_particles: Node2D = $FlipNode/DashParticles

@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/Idle
@onready var running_state: LimboState = $LimboHSM/Running
@onready var jumping_state: LimboState = $LimboHSM/Jumping
@onready var airborne_state: LimboState = $LimboHSM/Airborne
@onready var dashing_state: LimboState = $LimboHSM/Dashing
@onready var piling_state: LimboState = $LimboHSM/Piling

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var leaf_enter_audio: AudioStreamPlayer2D = $Audio/LeafEnter
@onready var leaf_exit_audio: AudioStreamPlayer2D = $Audio/LeafExit

### DYNAMIC VARIABLES ###
var cutscene_mode: bool = false

var current_health: int
var look_direction: float = 1.0 # <0 is left, >=0 is right
var jump_queued: bool = false
var leaf_meter: float = 0.0

var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var time_since_on_floor: float = 0.0
var time_since_jump_queued: float = 0.0

### SIGNALS ###
signal player_knocked_out
signal health_changed(new_health: int)
signal leaf_meter_changed(new_value: float)

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
	health_changed.emit(current_health)
	
	var dialogue_manager: Object = Engine.get_singleton(&"DialogueManager")
	if (dialogue_manager != null):
		dialogue_manager.dialogue_started.connect(enable_cutscene_mode.unbind(1))
		dialogue_manager.dialogue_ended.connect(disable_cutscene_mode.unbind(1))

# Compute gravity, move_and_slide, & flip Player sprite based on look direction.
func _physics_process(delta: float) -> void:
	add_debug_parameters()
	
	# If in cutscene state, do not check for these
	if (not cutscene_mode):
		update_jump_queue(delta)
		update_leaf_meter(delta)
	
	if ((not dashing_state.is_active()) and (not piling_state.is_active())):
		velocity.y += compute_gravity() * delta
		velocity.y = clampf(velocity.y, -INF, terminal_velocity) # velocity cannot exceed terminal velocity
		
		if (look_direction < 0): # Flip root node to Player's look direction
			flip_node.scale.x = -1.0
		else:
			flip_node.scale.x = 1.0
	
	move_and_slide()
	
	# Update floor-dependent variables.
	# This MUST be done AFTER move_and_slide(), which updates is_on_floor().
	if is_on_floor():
		time_since_on_floor = 0.0
	else:
		time_since_on_floor += delta

# Adds state transitions & initializes state machine.
func initialize_state_machine() -> void:
	# Idle State
	state_machine.add_transition(idle_state,running_state,&"to_running")
	state_machine.add_transition(idle_state,jumping_state,&"to_jumping")
	state_machine.add_transition(idle_state,airborne_state,&"to_airborne")
	state_machine.add_transition(idle_state,dashing_state,&"to_dashing")
	state_machine.add_transition(idle_state,piling_state,&"to_piling")
	
	# Running State
	state_machine.add_transition(running_state,idle_state,&"to_idle")
	state_machine.add_transition(running_state,jumping_state,&"to_jumping")
	state_machine.add_transition(running_state,airborne_state,&"to_airborne")
	state_machine.add_transition(running_state,dashing_state,&"to_dashing")
	state_machine.add_transition(running_state,piling_state,&"to_piling")
	
	# Jumping State
	state_machine.add_transition(jumping_state,airborne_state,&"to_airborne")
	state_machine.add_transition(jumping_state,dashing_state,&"to_dashing")
	state_machine.add_transition(jumping_state,piling_state,&"to_piling")
	
	# Airborne State
	state_machine.add_transition(airborne_state,idle_state,&"to_idle")
	state_machine.add_transition(airborne_state,running_state,&"to_running")
	state_machine.add_transition(airborne_state,dashing_state,&"to_dashing")
	state_machine.add_transition(airborne_state,piling_state,&"to_piling")
	
	# Dashing State
	state_machine.add_transition(dashing_state,idle_state,&"to_idle")
	state_machine.add_transition(dashing_state,running_state,&"to_running")
	state_machine.add_transition(dashing_state,airborne_state,&"to_airborne")
	
	# Piling State
	state_machine.add_transition(piling_state,idle_state,&"to_idle")
	state_machine.add_transition(piling_state,running_state,&"to_running")
	state_machine.add_transition(piling_state,airborne_state,&"to_airborne")
	
	state_machine.initial_state = idle_state
	state_machine.initialize(self)
	state_machine.set_active(true)

# If the player is idling (not moving or trying to move), change to idle state.
func check_idle_state() -> void:
	if is_on_floor():
		var velocity_is_zero: bool = (velocity == Vector2.ZERO)
		var x_input_is_zero: bool = (get_x_input() == 0.0)
		
		if velocity_is_zero and x_input_is_zero:
			if(state_machine.get_active_state()==dashing_state||state_machine.get_active_state()==piling_state):
				leaf_exit_audio.play()
			state_machine.dispatch(&"to_idle")

# If the player is moving on the ground, change to running state.
func check_running_state() -> void:
	if is_on_floor():
		var x_input_not_zero: bool = (get_x_input() != 0.0)
		var x_velocity_not_zero: bool = (velocity.x != 0.0)
		
		if x_input_not_zero or x_velocity_not_zero:
			state_machine.dispatch(&"to_running")

# If the player queued a jump & is on floor or within coyote time, change to jumping state.
func check_jumping_state() -> void:
	if (cutscene_mode):	# Do not handle input actions in Cutscene Mode
		return
	
	if jump_queued:
		var is_within_coyote_time: bool = (time_since_on_floor <= jump_coyote_time)
		if is_on_floor() or is_within_coyote_time:
			state_machine.dispatch(&"to_jumping")

# If the player is airborne AND the coyote timer has expired, change to airborne state.
func check_airborne_state() -> void:
	var is_coyote_timer_expired: bool = (time_since_on_floor > jump_coyote_time)
	if not is_on_floor() and is_coyote_timer_expired:
		if(state_machine.get_active_state()==dashing_state||state_machine.get_active_state()==piling_state):
			leaf_exit_audio.play()
		state_machine.dispatch(&"to_airborne")

# If the player is trying to dash, has a non-zero leaf meter, AND is holding no direction, change to piling state.
func check_dashing_state() -> void:
	if (cutscene_mode):	# Do not handle input actions in Cutscene Mode
		return
	
	if Input.is_action_just_pressed(&"dash"):
		var is_leaf_meter_not_empty: bool = (leaf_meter > 0.0)
		var is_direction_pressed: bool = (Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO)
		
		if is_direction_pressed and is_leaf_meter_not_empty:
			leaf_enter_audio.play()
			state_machine.dispatch(&"to_dashing")

# If the player is trying to dash, has a non-zero leaf meter, AND is holding no direction, change to piling state.
func check_piling_state() -> void:
	if (cutscene_mode):	# Do not handle input actions in Cutscene Mode
		return
	
	if Input.is_action_just_pressed(&"dash"):
		var is_leaf_meter_not_empty: bool = (leaf_meter > 0.0)
		var is_no_direction_pressed: bool = (Input.get_vector("move_left", "move_right", "move_up", "move_down") == Vector2.ZERO)
		
		if is_no_direction_pressed and is_leaf_meter_not_empty:
			leaf_enter_audio.play()
			state_machine.dispatch(&"to_piling")

## Enables the Player's Cutscene Mode & returns the Cutscene Mode's new value
func enable_cutscene_mode() -> bool:
	return set_cutscene_mode(true)

## Disables the Player's Cutscene Mode & returns the Cutscene Mode's new value
func disable_cutscene_mode() -> bool:
	return set_cutscene_mode(false)

## Sets the Player's Cutscene Mode & returns the Cutscene Mode's new value
func set_cutscene_mode(value: bool) -> bool:
	cutscene_mode = value
	return cutscene_mode

# Get the input direction and handle the movement/deceleration.
func move_horizontal(acceleration: float, deceleration: float, turn_speed: float) -> void:
	
	var direction: float = get_x_input()
	var new_velocity: float = 0.0
	
	if (is_on_wall()):
		new_velocity = 0.0
	elif (direction == 0.0) and (state_machine.get_previous_active_state() != dashing_state): # No direction & did not exit Leaf Dash
		new_velocity = move_toward(velocity.x, 0, deceleration)

	else:
		var new_acceleration: float = 0.0
		
		if (signf(direction) == signf(velocity.x)): 	# Direction matches current velocity
			new_acceleration = direction * acceleration
		else: 											# Direction is opposite to current velocity
			new_acceleration = direction * turn_speed
		
		## Determine velocity debt AKA how much velocity beyond the max speed the Player has
		#var velocity_debt: float = abs(velocity.x) - run_max_speed
		#if (is_on_floor()):
			#velocity_debt -= ground_friction	# Apply friction to velocity debt
		#print("Velocity Debt: ", velocity_debt)
		#
		#if (velocity_debt > 0):		# If velocity debt exists
			#
			#var capped_new_velocity: float = clampf(velocity.x, -run_max_speed, run_max_speed)
			#var signed_velocity_debt: float = velocity_debt * signf(velocity.x)	# Change sign to proper movement direction
			#
			#new_velocity = capped_new_velocity + signed_velocity_debt
			#
			#new_velocity = clampf(new_velocity + new_acceleration, -new_velocity, new_velocity)
		
		# If just exited Leaf Dash, limit velocity by dash max speed
		if (piling_state.is_active()):
			if (is_on_floor()):
				new_velocity = clampf(velocity.x + new_acceleration, -pile_max_speed_ground, pile_max_speed_ground)
			else:
				new_velocity = clampf(velocity.x + new_acceleration, -pile_max_speed_air, pile_max_speed_air)
		elif (state_machine.get_previous_active_state() == dashing_state) and (abs(velocity.x) > run_max_speed):
			new_velocity = clampf(velocity.x + new_acceleration, -dash_max_speed, dash_max_speed)
		else:
			new_velocity = clampf(velocity.x + new_acceleration, -run_max_speed, run_max_speed)
		#print("New Velocity: ", new_velocity)
	
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

# Calls move_horizontal with pile ground parameters.
func move_horizontal_pile_ground() -> void:
	move_horizontal(pile_ground_acceleration, pile_ground_deceleration, pile_ground_turn_speed)

# Calls move_horizontal with pile air parameters.
func move_horizontal_pile_air() -> void:
	move_horizontal(pile_air_acceleration, pile_air_deceleration, pile_air_turn_speed)

# Returns the player's x-input value.
func get_x_input() -> float:
	if (cutscene_mode):
		return 0.0
	else:
		return Input.get_axis(&"move_left", &"move_right")

# Updates jump velocity & gravity variables
func compute_jump_parameters() -> void:
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak ** 2)) * -1.0

func compute_gravity() -> float:
	var new_velocity: float

	# Control variable jump height by checking is "jump" is being held
	if (state_machine.get_active_state() == jumping_state) and Input.is_action_pressed(&"jump"):
		new_velocity = jump_gravity
	else:
		new_velocity = jump_gravity * fall_gravity_multiplier
	
	return new_velocity

# Queues a new jump or updates/expires the timer since a jump was queued.
func update_jump_queue(delta: float) -> void:
	if jump_queued:
		time_since_jump_queued += delta
		#print(time_since_jump_queued)
		if (time_since_jump_queued > jump_buffer_time):	# Check if jump has been queued for too long
			jump_queued = false							# Jump loses its queue
	elif Input.is_action_just_pressed(&"jump"):
		jump_queued = true
		time_since_jump_queued = 0.0

# Add y-velocity to make the player "jump".
func jump() -> void:
	jump_queued = false # Free jump queue
	velocity.y = jump_velocity
	time_since_on_floor = INF	# Prevent additional coyote jumps
	#print(jump_velocity)

func update_leaf_meter(delta: float) -> void:
	var new_leaf_meter: float = leaf_meter
	
	# Compute change in leaf meter
	var leaf_meter_change: float = 0.0
	
	if (dashing_state.is_active()):
		leaf_meter_change = -1.0 * meter_dash_drain_rate
	elif (piling_state.is_active()):
		leaf_meter_change = -1.0 * meter_pile_drain_rate
	elif ((state_machine.get_previous_active_state() == dashing_state) or (state_machine.get_previous_active_state() == piling_state)): # Do not change Leaf Meter post-dash until Player hits the ground
		leaf_meter_change = 0.0
	elif (signf(get_x_input()) != signf(velocity.x)): # If turning
		leaf_meter_change = 0.0
	elif (velocity != Vector2.ZERO):
		leaf_meter_change = meter_buildup_rate
	else:
		leaf_meter_change = -1.0 * meter_drain_rate
	
	new_leaf_meter += (leaf_meter_change * delta)
	
	set_leaf_meter(new_leaf_meter)

# Decreases the Player's health by the given value.
func hurt(damage: int) -> void:
	set_health(current_health - damage)

# Set the Player's current health, update the health UI, and check for Player knockout
func set_health(new_health: int) -> void:
	if (cutscene_mode):
		push_warning("set_health(): Cutscene Mode active, health not set.")
		return
	
	if (new_health > health):	# If health greater than max health
		push_warning("set_health(): new_health is greater than max health.")
	
	current_health = clampi(new_health, 0, health)
	health_changed.emit(current_health)
	
	if (current_health <= 0):
		player_knocked_out.emit()

# Sets the Player's current Leaf Meter & updates the Leaf Meter UI.
func set_leaf_meter(new_leaf_meter: float) -> void:
	if (cutscene_mode):
		push_warning("set_leaf_meter(): Cutscene Mode active, Leaf Meter not set.")
		return
	
	leaf_meter = clampf(new_leaf_meter, 0.0, 100.0)
	leaf_meter_changed.emit(leaf_meter)

# Resets the Player's health and Leaf Meter to their initial values.
func reset_stats() -> void:
	set_health(health)
	set_leaf_meter(0.0)

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
		ground_friction = data["ground_friction"]
		
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
		meter_pile_drain_rate = data["meter_pile_drain_rate"]
		
		dash_max_speed = data["dash_max_speed"]
		dash_angular_turn_speed = data["dash_angular_turn_speed"]
		dash_deceleration = data["dash_deceleration"]
		dash_angular_turn_speed_deceleration = data["dash_angular_turn_speed_deceleration"]
		meter_dash_deceleration_start = data["meter_dash_deceleration_start"]
		
		pile_gravity = data["pile_gravity"]
		pile_terminal_velocity = data["pile_terminal_velocity"]

		pile_max_speed_ground = data["pile_max_speed_ground"]
		pile_ground_acceleration = data["pile_ground_acceleration"]
		pile_ground_deceleration = data["pile_ground_deceleration"]
		pile_ground_turn_speed = data["pile_ground_turn_speed"]
		pile_ground_friction = data["pile_ground_friction"]

		pile_max_speed_air = data["pile_max_speed_air"]
		pile_air_acceleration = data["pile_air_acceleration"]
		pile_air_deceleration = data["pile_air_deceleration"]
		pile_air_turn_speed = data["pile_air_turn_speed"]
		
		fun_value = data["fun_value"]

func add_debug_parameters() -> void:
	#DebugMenu.add_debug_property("Player State", state_machine.get_active_state().name, 0)
	#DebugMenu.add_debug_property("Player Cutscene Mode", cutscene_mode, 0)
	#DebugMenu.add_debug_property("Player Velocity", velocity, 5)
	pass
