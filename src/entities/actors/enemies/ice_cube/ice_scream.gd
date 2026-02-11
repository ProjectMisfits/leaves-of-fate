extends Enemy
class_name IceScream
#States
@onready var idle_state : LimboState = $LimboHSM/Idle
@onready var chase_normal_state : LimboState = $LimboHSM/ChaseNormal
@onready var chase_angry_state : LimboState = $LimboHSM/ChaseAngry
@onready var grabbed_state : LimboState = $LimboHSM/Grabbed
@onready var death_state : LimboState = $LimboHSM/Death
@onready var ice_cube_sprite : Sprite2D = $FlipNode/Sprite2D

#Grabbable area
@onready var grab_collision : CollisionShape2D = $GrabbableArea/CollisionShape2D

@export var database : JSON = null

@onready var animation_player : AnimationPlayer = $AnimationPlayer


#Acceleration when charging normally
var normal_acceleration : float 
#Acceleration when charging normally
var normal_deceleration : float 
#Acceleration when charging normally
var angry_acceleration : float 
#turn speed
var turn_speed: float
#max speed
var max_speed: float
#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int 
#The range at which the ice cube needs to get near the last know position of the player
var end_range : int




func _enter_tree() -> void:
	if (database != null):
		var db_data: Dictionary = database.data
		initialize_data(db_data)
	else:
		push_error("Database is equal to 'null'.")
		
func initialize_data(data: Dictionary) -> void:
	normal_acceleration = data["normal_acceleration"]
	normal_deceleration = data["normal_deceleration"]
	angry_acceleration = data["angry_acceleration"]
	gravity = data["gravity"]
	end_range = data["end_range"]
	turn_speed = data["turn_speed"]
	max_speed = data["max_speed"]

func _ready() -> void:
	super()
	
	
func intialize_statemachine() -> void:
	#Add all the state machine stuff
	state_machine.add_transition(idle_state,chase_normal_state,&"to_chase_normal")
	state_machine.add_transition(chase_normal_state,idle_state,&"to_idle")
	state_machine.add_transition(chase_angry_state,idle_state,&"to_idle")
	state_machine.add_transition(idle_state,grabbed_state,&"to_grabbed")
	state_machine.add_transition(chase_normal_state,grabbed_state,&"to_grabbed")
	state_machine.add_transition(grabbed_state,chase_angry_state,&"to_chase_angry")
	state_machine.add_transition(state_machine.ANYSTATE,death_state,&"to_death")
	state_machine.initial_state = idle_state
	super()

func _physics_process(delta: float) -> void:
	#apply gravity at all times

	velocity.y += gravity * delta
	move_and_slide()

func check_for_player() -> void:
	if(check_player_visible()):
		state_machine.dispatch(&"to_chase_normal")


#Checking if the cube has reached the player
func check_reached_player() -> void:
	#Make sure that the player is not still visible even if you have reached the destination
		#if its within a certain pixel range pixels of the players last known position
		if abs(player_last_known_pos.x)-abs(global_position.x) < end_range and look_direction == 1:
			print("stop")
			state_machine.dispatch(&"to_idle")
		elif abs(global_position.x) - abs(player_last_known_pos.x) < end_range and  look_direction == -1:
			state_machine.dispatch(&"to_idle")

	

#function to reset all of the cubes properties
func reset() -> void:
	grab_collision.set_deferred("disabled",false)
	ice_cube_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	velocity.x = 0
	player_last_known_pos = Vector2.ZERO

	

func move_normal(delta:float) -> void:
	move_horizontal(look_direction,normal_acceleration,normal_deceleration,delta,turn_speed,max_speed)

func move_idle(delta:float) -> void:
	move_horizontal(0,0,normal_deceleration,delta,turn_speed,max_speed)
	
func move_angry(delta:float) -> void:
	move_horizontal(look_direction,angry_acceleration,0,delta,turn_speed,max_speed)
	

#Checking if the ice cube has hit a wall, this stops an angry charge
func check_wall() -> void:
	if is_on_wall():
		state_machine.dispatch(&"to_idle")

#Initiating the grabed state 
func companion_action_triggered() -> void:
	state_machine.dispatch(&"to_grabbed")
	

#Check whether or not the player as released the cube 
func check_release(delay: bool) -> void:
	if(Input.is_action_just_pressed("companion") and delay):
		if(not player_last_known_pos == Vector2.ZERO):
			state_machine.dispatch(&"to_chase_angry")
		else:
			state_machine.dispatch(&"to_idle")

#What happens when the cube is grabbed
func _grab() -> void:
	grab_collision.set_deferred("disabled",true)
	velocity.x = 0;
	
	
#If the ice cube collides with another ice cube or spike at ANY state it should explode
func _on_hurt_area_body_entered(body: Node2D) -> void:
	if(not body == self):
		state_machine.dispatch(&"to_death")
		#this ensures that both this cube dies and the other one dies as well
		if(body is IceScream):
			body.death()
	
