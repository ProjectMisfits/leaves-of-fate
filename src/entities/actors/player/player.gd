# Jump math comes from the GDC Talk "Math for Game Programmers: Building a Better Jump
# Source: https://www.youtube.com/watch?v=hG9SzQxaCm8
## Controllable Player which can run, jump, and go into a Leaf Dash or Pile.
extends CharacterBody2D
class_name Player

# -------------------- RESOURCES -------------------- #
@export var database: JSON = null

# -------------------- DATABASE VARIABLES -------------------- #
var max_health: int					## The Player's maximum health.
var terminal_velocity: float		## The Player's maximum positive Y-velocity.

# ---------- Run ---------- #
var run_max_speed: float			## The Player's maximum X-velocity when running. The Player's actual X-velocity may exceed this value if forces beside running momentum are applied.
var ground_acceleration: float		## The Player's X-velocity gain per second while running.
var ground_deceleration: float		## The Player's X-velocity loss per second while not running & on the ground.
var ground_turn_speed: float		## The Player's X-velocity gain per second while turning to run in the opposite direction on the ground.
var ground_friction: float			## UNUSED: The Player's X-velocity loss per second while over their max run speed.

var air_acceleration: float			## The Player's X-velocity gain per second while moving in the air.
var air_deceleration: float			## The Player's X-velocity loss per second while in the air and not moving.
var air_turn_speed: float			## The Player's X-velocity gain per second while turning to move in the opposite direction in the air.

# ---------- Jump ---------- #
var jump_height: float						## How high the peak of the Player's jump reaches in world units.
var jump_time_to_peak: float				## How long (in seconds) it takes for the Player to reach the peak of their jump.
var fall_gravity_multiplier: float			## Multiplier for gravitational pull which applies if the Player is jumping and releases the jump button. This enables variable jump height.
var jump_coyote_time: float					## How long (in seconds) after starting to fall where the Player may still initiate a jump.
var jump_buffer_time: float					## How long (in seconds) before landing on the ground where the Player may "queue" a jump to trigger as soon as they land.
var jump_corner_rounding_distance: float	## UNUSED: How close (in game units) the Player must be to a ledge before they slide onto it at the peak of their jump.

# ---------- Leaf Dash ---------- #
var meter_buildup_rate: float		## The amount of wind per second that the Player generates while moving.
var meter_drain_rate: float			## The amount of wind per second that the Player loses while NOT moving.
var meter_dash_drain_rate: float	## The amount of wind per second that the Player loses while Leaf Dashing.
var meter_dash_end_drain: float		## The amount of wind drained after ending a Leaf Dash.
var meter_pile_drain_rate: float	## The amount of wind per second that the Player loses while in Leaf Pile mode.

var dash_max_speed: float						## The Player's speed while Leaf Dashing.
var dash_angular_turn_speed: float				## The Player's turn speed (in degrees) while Leaf Dashing. Not scaled by delta time.
var dash_deceleration: float					## UNUSED: The Player's speed loss per second while Leaf Dashing with very little wind left.
var dash_angular_turn_speed_deceleration: float	## UNUSED: The Player's turn speed loss per second while Leaf Dashing with very little wind left.
var meter_dash_deceleration_start: float		## UNUSED: If the Player is Leaf Dashing with this amount of wind or less in their Leaf Meter, they begin slowing down.
var dash_end_velocity_multiplier: float			## When ending a Leaf Dash, multiply velocity by this value to "fling" the Player.

var post_dash_gravity: float						## Gravity applied to Player during the post-dash mode.
var post_dash_fast_fall_gravity_multiplier: float	## Multiplier for Player gravity while pressing the move_down action during the post-dash mode.

# ---------- Leaf Pile ---------- #
var pile_gravity: float					## The Player's gravity while in Leaf Pile mode.
var pile_terminal_velocity: float		## The Player's maximum downward Y-velocity while in Leaf Pile mode.

var pile_max_speed_ground: float		## The Player's maximum X-velocity while in Leaf Pile mode & on the ground. The Player's actual X-velocity may exceed this value if forces beside moving momentum are applied.
var pile_ground_acceleration: float		## The Player's X-velocity gain per second while moving in Leaf Pile mode & on the ground.
var pile_ground_deceleration: float		## The Player's X-velocity loss per second while not moving in Leaf Pile mode & on the ground.
var pile_ground_turn_speed: float		## The Player's X-velocity gain per second while turning to move in the opposite direction in Leaf Pile mode & on the ground.
var pile_ground_friction: float			## UNUSED: The Player's X-velocity loss per second while over their max ground speed in Leaf Pile mode.

var pile_max_speed_air: float			## The Player's maximum X-velocity while in Leaf Pile mode & in the air. The Player's actual X-velocity may exceed this value if forces beside moving momentum are applied.
var pile_air_acceleration: float		## The Player's X-velocity gain per second while moving in Leaf Pile mode & in the air.
var pile_air_deceleration: float		## The Player's X-velocity loss per second while NOT moving in Leaf Pile mode & in the air.
var pile_air_turn_speed: float			## The Player's X-velocity gain per second while turning to move in the opposite direction in Leaf Pile mode & in the air.

# ---------- Misc. ---------- #
var hit_recoil_velocity: float			## How far the Player is launched after being hit.
var hit_recoil_direction: Vector2		## The direction the Player is launched after being hit.
var hit_invincibility_time: float		## How long after being hit that the Player is invincible for.
var fun_value: int						## Every copy of Project Misfits is personalized.

# -------------------- NODE REFERENCES -------------------- #
## Reference to the Player's Collision Shape. Its shape is switched when
## the Player enters Leaf mode.
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## Reference to the Player's FlipNode.
## The FlipNode's scale changes depending on the Player's look direction;
## all children of the Node are flipped.
@onready var flip_node: Node2D = $FlipNode

## Reference to the Player's DashParticles container Node.
## When Leaf Dashing, all children (assumed to be particle systems) are set to "emitting".
@onready var dash_particles: Node2D = $FlipNode/DashParticles

## Reference to the Player's AnimationPlayer Node, which is used to switch to
## different animations depending on the Player's state.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## AnimationPlayer with an "invincibility" modulation animation.
## Plays on repeat until stopped manually.
@onready var invincibility_animation_player: AnimationPlayer = $InvincibilityAnimationPlayer

## While active, the Player is invincible & cannot be damaged normally.
@onready var invincibility_timer: Timer = $InvincibilityTimer

# ---------- State Machine & States ---------- #
@onready var state_machine: LimboHSM = $LimboHSM				## Reference to the Player's State Machine.
@onready var idle_state: LimboState = $LimboHSM/Idle			## Reference to the Player's Idle State.
@onready var running_state: LimboState = $LimboHSM/Running		## Reference to the Player's Running State.
@onready var jumping_state: LimboState = $LimboHSM/Jumping		## Reference to the Player's Jumping State.
@onready var airborne_state: LimboState = $LimboHSM/Airborne	## Reference to the Player's Airborne State.
@onready var dashing_state: LimboState = $LimboHSM/Dashing		## Reference to the Player's Leaf Dash State.
@onready var piling_state: LimboState = $LimboHSM/Piling		## Reference to the Player's Leaf Pile state.

# -------------------- DYNAMIC VARIABLES -------------------- #
## If True, disable all user input.
## The Player's process_mode is NOT disabled and they may still move & change states.
var cutscene_mode: bool = false

## If True, Player just exited a dash & is airborne.
## The Player may NOT Leaf Dash/Pile & has no air deceleration.
## After touching the ground, this becomes false again.
var post_dash_mode: bool = false

## If True, Player is invincible & cannot be damaged normally.
var invincible: bool = false

@onready var leaf_enter_audio: AudioStreamPlayer2D = $Audio/LeafEnter
@onready var leaf_exit_audio: AudioStreamPlayer2D = $Audio/LeafExit

var current_health: int			## The Player's current health remaining.
var look_direction: float = 1.0	## The direction the Player is looking. < 0 is left, >= 0 is right.
var jump_queued: bool = false	## If True, the user queued a jump which will trigger immediately when the Player lands on the ground.
var leaf_meter: float = 0.0		## How much wind the Player currently has.

## How much Y-velocity to add to the Player when a jump is initiated.
## Determined at runtime using the Jump database variables.
var jump_velocity: float = 0.0

## How much gravity to apply to the Player during a jump.
## Determined at runtime using the Jump database variables.
var jump_gravity: float = 0.0
var time_since_on_floor: float = 0.0	## How long (in seconds) the Player has been on the floor for. Used to validate a coyote time jump.
var time_since_jump_queued: float = 0.0	## How long (in seconds) since the Player queued a jump. Used to validate a buffered jump.

##Variable that determines if the player can build leaf meter or not
var can_build_wind : bool = true

# -------------------- SIGNALS -------------------- #
signal player_knocked_out					## Emitted when the Player loses all of their health.
signal health_changed(new_health: int)		## Emitted when the Player's health changes.
signal leaf_meter_changed(new_value: float)	## Emitted when the Player's stored wind changes.

## Fetch database resource. If valid, initialize all variables.
func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")

## Initializes state machine & computes jump variables for later use.
func _ready() -> void:
	initialize_state_machine()
	compute_jump_parameters()
	
	current_health = max_health
	health_changed.emit(current_health)
	
	var dialogue_manager: Object = Engine.get_singleton(&"DialogueManager")
	if (dialogue_manager != null):
		dialogue_manager.dialogue_started.connect(enable_cutscene_mode.unbind(1))
		dialogue_manager.dialogue_ended.connect(disable_cutscene_mode.unbind(1))

## Compute gravity, move_and_slide, & flip Player sprite based on look direction.
func _physics_process(delta: float) -> void:
	add_debug_parameters()
	
	if (post_dash_mode and is_on_floor()):	# If landed on floor during post-dash mode, disable post-dash mode.
		post_dash_mode = false
	
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

## Adds state transitions & initializes state machine.
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

## If the player is idling (not moving or trying to move), change to idle state.
func check_idle_state() -> void:
	if is_on_floor():
		var velocity_is_zero: bool = (velocity == Vector2.ZERO)
		var x_input_is_zero: bool = (get_x_input() == 0.0)
		
		if velocity_is_zero and x_input_is_zero:
			if(state_machine.get_active_state()==dashing_state||state_machine.get_active_state()==piling_state):
				leaf_exit_audio.play()
			state_machine.dispatch(&"to_idle")

## If the player is moving on the ground, change to running state.
func check_running_state() -> void:
	if is_on_floor():
		var x_input_not_zero: bool = (get_x_input() != 0.0)
		var x_velocity_not_zero: bool = (velocity.x != 0.0)
		
		if x_input_not_zero or x_velocity_not_zero:
			state_machine.dispatch(&"to_running")

## If the player queued a jump & is on floor or within coyote time, change to jumping state.
func check_jumping_state() -> void:
	if (cutscene_mode):	# Do not handle input actions in Cutscene Mode
		return
	
	if jump_queued:
		var is_within_coyote_time: bool = (time_since_on_floor <= jump_coyote_time)
		if is_on_floor() or is_within_coyote_time:
			state_machine.dispatch(&"to_jumping")

## If the player is airborne AND the coyote timer has expired, change to airborne state.
func check_airborne_state() -> void:
	var is_coyote_timer_expired: bool = (time_since_on_floor > jump_coyote_time)
	if not is_on_floor() and is_coyote_timer_expired:
		if(state_machine.get_active_state()==dashing_state||state_machine.get_active_state()==piling_state):
			leaf_exit_audio.play()
		state_machine.dispatch(&"to_airborne")

## If the player is trying to dash, has a non-zero leaf meter, AND is holding no direction, change to piling state.
func check_dashing_state() -> void:
	if (cutscene_mode):	# Do not handle input actions in Cutscene Mode
		return
	
	if Input.is_action_just_pressed(&"dash"):
		var is_leaf_meter_not_empty: bool = (leaf_meter > 0.0)
		var is_direction_pressed: bool = (Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO)
		
		if is_direction_pressed and is_leaf_meter_not_empty:
			leaf_enter_audio.play()
			state_machine.dispatch(&"to_dashing")

## If the player is trying to dash, has a non-zero leaf meter, AND is holding no direction, change to piling state.
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

## Get the input direction and handle the movement/deceleration.
func move_horizontal(acceleration: float, deceleration: float, turn_speed: float, delta: float) -> void:
	
	var direction: float = get_x_input()
	var new_velocity: float = 0.0
	
	if (direction == 0.0) and (not post_dash_mode): # No direction & not in post-dash mode
		new_velocity = move_toward(velocity.x, 0, deceleration * delta)
	else:
		var new_acceleration: float = 0.0
		
		if (signf(direction) == signf(velocity.x)): 	# Direction matches current velocity
			new_acceleration = direction * acceleration * delta
		else: 											# Direction is opposite to current velocity
			new_acceleration = direction * turn_speed * delta
		
		# If just exited Leaf Dash, limit velocity by dash max speed
		if (piling_state.is_active()):	# Player in Leaf Pile mode
			if (is_on_floor()):
				new_velocity = clampf(velocity.x + new_acceleration, -pile_max_speed_ground, pile_max_speed_ground)
			else:
				new_velocity = clampf(velocity.x + new_acceleration, -pile_max_speed_air, pile_max_speed_air)
		elif (abs(velocity.x) > run_max_speed):	# If Player above max run speed, do not let them add additional move velocity
			# Trying to use clampf here with -velocity.x & velocity.x breaks the function,
			# causing it to always return a positive value. So instead, we clamp manually here.
			var temp_velocity: float = velocity.x + new_acceleration
			#print("MEWO")
			
			if (abs(temp_velocity) > abs(velocity.x)):
				new_velocity = velocity.x
			else:
				new_velocity = temp_velocity
			
			
			# If on floor, decrease velocity by ground friction. Also enables bunny-hopping and ground-dashing.
			if (is_on_floor()):
				# Decrease velocity by ground friction, stop once velocity equals max run speed.
				new_velocity = move_toward(new_velocity, run_max_speed * signf(new_velocity), ground_friction * delta)
		else:	# Player moving regularly, on the ground OR in the air
			# TODO: If velocity is over max run speed, decrease velocity by ground friction
			new_velocity = clampf(velocity.x + new_acceleration, -run_max_speed, run_max_speed)
		#print("New Velocity: ", new_velocity)
	
	velocity.x = new_velocity
	
	# Pos/0 velocity = look right, neg velocity = look left
	var new_look_direction: float = signf(direction)
	look_direction = new_look_direction if (new_look_direction != 0.0) else look_direction

## Calls move_horizontal with ground parameters.
func move_horizontal_ground(delta: float) -> void:
	move_horizontal(ground_acceleration, ground_deceleration, ground_turn_speed, delta)

## Calls move_horizontal with air parameters.
func move_horizontal_air(delta: float) -> void:
	move_horizontal(air_acceleration, air_deceleration, air_turn_speed, delta)

## Returns the player's normalized x-input value.
func get_x_input() -> float:
	if (cutscene_mode):
		return 0.0
	else:
		return ceilf(Input.get_axis(&"move_left", &"move_right"))	# Ceilf to get normalized input.

## Updates jump velocity & gravity variables
func compute_jump_parameters() -> void:
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak ** 2)) * -1.0

## Returns the Player's gravity, which varies depending on whether they are jumping & holding the jump button or not.
func compute_gravity() -> float:
	var new_gravity: float

	# Control variable jump height by checking is "jump" is being held
	if (state_machine.get_active_state() == jumping_state) and Input.is_action_pressed(&"jump"):
		new_gravity = jump_gravity
	elif (post_dash_mode):
		if (Input.is_action_pressed(&"move_down")):	# If in post-dash AND pressing move_down key
			new_gravity = post_dash_gravity * post_dash_fast_fall_gravity_multiplier
		else:
			new_gravity = post_dash_gravity
	else:
		new_gravity = jump_gravity * fall_gravity_multiplier
	
	return new_gravity

## Queues a new jump or updates/expires the timer since a jump was queued.
func update_jump_queue(delta: float) -> void:
	if jump_queued:
		time_since_jump_queued += delta
		#print(time_since_jump_queued)
		if (time_since_jump_queued > jump_buffer_time):	# Check if jump has been queued for too long
			jump_queued = false							# Jump loses its queue
	elif Input.is_action_just_pressed(&"jump"):
		jump_queued = true
		time_since_jump_queued = 0.0

## Update how much wind the Player has stored according to their current state.
func update_leaf_meter(delta: float) -> void:
	var new_leaf_meter: float = leaf_meter
	
	# Compute change in leaf meter
	var leaf_meter_change: float = 0.0
	
	if (dashing_state.is_active()):
		leaf_meter_change = -1.0 * meter_dash_drain_rate
	elif (piling_state.is_active()):
		leaf_meter_change = -1.0 * meter_pile_drain_rate
	elif (post_dash_mode): # Do not change Leaf Meter post-dash until Player hits the ground
		leaf_meter_change = 0.0
	elif (signf(get_x_input()) != signf(velocity.x)): # If turning
		leaf_meter_change = 0.0
	elif (velocity != Vector2.ZERO and can_build_wind):
		leaf_meter_change = meter_buildup_rate
	else:
		leaf_meter_change = -1.0 * meter_drain_rate
	
	new_leaf_meter += (leaf_meter_change * delta)
	
	set_leaf_meter(new_leaf_meter)

##Sets if the player can build leaf meter
func set_can_build_wind(new_build_wind : bool) -> void:
	can_build_wind = new_build_wind

##Gets if the player can build leaf meter 
func get_can_build_wind() -> bool:
	return can_build_wind

## Decreases the Player's health by the given value.
func hurt(damage: int) -> void:
	if (invincible):
		return	# Do not deal damage.
	else:
		set_health(current_health - damage)
		cutscene_mode = true	# Temporarily disable user controls.
		
		# Launch the Player in the reverse of their look direction by an amount.
		velocity = hit_recoil_direction.normalized() * hit_recoil_velocity * ceilf(look_direction)
		
		animation_player.play(&"player_hitstun")
		
		await animation_player.animation_finished
		
		cutscene_mode = false	# Re-enable user controls.
		start_invincibility(hit_invincibility_time)	# Make Player invincible for an amount of time.

## Make the Player invincible & starts the Invincibility Timer.
func start_invincibility(time: float) -> void:
	if (time <= 0.0):
		push_warning("start_invincibility(): given time is 0.0 or less.")
		return
	
	invincible = true
	invincibility_timer.start(time)
	invincibility_animation_player.play(&"hit_invincibility")

## Run once the Invincibility Timer ends.
## Ends the Player's invincibility.
func _end_invincibility() -> void:
	if (not invincible):
		push_warning("end_invincibility(): Player is not currently invincible.")
		return
	
	invincible = false
	invincibility_animation_player.stop()

## Set the Player's current health, update the health UI, and check for Player knockout.
## Health set in this way disregards invincibility.
func set_health(new_health: int) -> void:
	if (cutscene_mode):
		push_warning("set_health(): Cutscene Mode active, health not set.")
		return
	
	if (new_health > max_health):	# If health greater than max health
		push_warning("set_health(): new_health is greater than max health.")
	
	current_health = clampi(new_health, 0, max_health)
	health_changed.emit(current_health)
	
	if (current_health <= 0):
		player_knocked_out.emit()

## Sets the Player's current Leaf Meter & updates the Leaf Meter UI.
func set_leaf_meter(new_leaf_meter: float) -> void:
	if (cutscene_mode):
		push_warning("set_leaf_meter(): Cutscene Mode active, Leaf Meter not set.")
		return
	
	leaf_meter = clampf(new_leaf_meter, 0.0, 100.0)
	leaf_meter_changed.emit(leaf_meter)

## Resets the Player's health and Leaf Meter to their initial values.
func reset_stats() -> void:
	set_health(max_health)
	set_leaf_meter(0.0)
	
	# Reset state. Uses call_deferred() to allow the current state's exit function to run.
	state_machine.call_deferred("change_active_state", idle_state)

## Initializes all variables to values extracted from the entity's database.
func initialize_data(data: Dictionary) -> void:
		# Base Data #
		max_health = data["max_health"]
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
		meter_dash_end_drain = data["meter_dash_end_drain"]
		
		dash_max_speed = data["dash_max_speed"]
		dash_angular_turn_speed = data["dash_angular_turn_speed"]
		dash_deceleration = data["dash_deceleration"]
		dash_angular_turn_speed_deceleration = data["dash_angular_turn_speed_deceleration"]
		meter_dash_deceleration_start = data["meter_dash_deceleration_start"]
		dash_end_velocity_multiplier = data["dash_end_velocity_multiplier"]
		
		post_dash_gravity = data["post_dash_gravity"]
		post_dash_fast_fall_gravity_multiplier = data["post_dash_fast_fall_gravity_multiplier"]
		
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
		
		hit_recoil_velocity = data["hit_recoil_velocity"]
		hit_recoil_direction = data["hit_recoil_direction"]
		hit_invincibility_time = data["hit_invincibility_time"]
		fun_value = data["fun_value"]

## Adds various Player variables to the Debug Menu.
func add_debug_parameters() -> void:
	DebugMenu.add_debug_property("Player State", state_machine.get_active_state().name, 0)
	DebugMenu.add_debug_property("Player Cutscene Mode", cutscene_mode, 0)
	DebugMenu.add_debug_property("Player Post-dash Mode", post_dash_mode, 0)
	DebugMenu.add_debug_property("Player Velocity", velocity, 5)
