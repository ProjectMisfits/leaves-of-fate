extends Enemey
class_name Ice_Scream
#States
@onready var idle_state : LimboState = $LimboHSM/Idle
@onready var chase_normal_state : LimboState = $LimboHSM/ChaseNormal
@onready var chase_angry_state : LimboState = $LimboHSM/ChaseAngry
@onready var grabbed_state : LimboState = $LimboHSM/Grabbed
@onready var death_state : LimboState = $LimboHSM/Death

#Speed when idle
const IDLE_SPEED : float = 10
#Speed when charging normally
const CHARGE_SPEED : float = 10
#Speed when charging ANGRY
const CHARGE_SPEED_ANGRY : float = 20
#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
#The range at which the ice cube needs to get near the last know position of the player
@export var end_range : int = 4



func _ready() -> void:
	super()
	
	
func intialize_statemachine()-> void:
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
	#print(look_direction)
	#print(player_last_known_pos)
	#apply gravity at all times
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func check_for_player()->void:
	if(check_player_visible()):
		begin_chase_normal()

#
func begin_chase_normal()-> void:
	$FlipNode/Sprite2D.modulate = Color(0.816, 0.346, 0.871, 1.0)
	
	state_machine.dispatch(&"to_chase_normal")

func _on_wait_before_chase_timeout() -> void:
	$FlipNode/Sprite2D.modulate = Color(0.812, 0.014, 0.477, 1.0)
	state_machine.dispatch(&"to_chase_normal")
	pass # Replace with function body.

#Checking if the cube has reached the player
func check_reached_player()->void:
	#Make sure that the player is not still visible even if you have reached the destination
	
		#if its within a certain pixel range pixels of the players last known position
		if abs(player_last_known_pos.x)-abs(global_position.x) < end_range and look_direction == 1:
			print("stop")
			state_machine.dispatch(&"to_idle")
		elif abs(global_position.x) - abs(player_last_known_pos.x) < end_range and  look_direction == -1:
			state_machine.dispatch(&"to_idle")
		pass
	

#function to reset all of the cubes properties
func reset()->void:
	$FlipNode/GrabbableArea/CollisionShape2D.set_deferred("disabled",false)
	$FlipNode/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	velocity.x = 0
	player_last_known_pos = Vector2.ZERO

#Function for moving the cube 
func move(speed:float,delta: float)->void:
	move_horizontal(look_direction,speed,delta)




#Checking if the ice cube has hit a wall, this stops an angry charge
func check_wall()->void:
	if is_on_wall():
		state_machine.dispatch(&"to_idle")

#Initiating the grabed state 
func companion_action_triggered()->void:
	state_machine.dispatch(&"to_grabbed")
	pass

#Check whether or not the player as released the cube 
func check_release()->void:
	if(Input.is_action_just_pressed("companion")):
		if(not player_last_known_pos == Vector2.ZERO):
			$FlipNode/Sprite2D.modulate = Color(1.0, 0.0, 0.145, 1.0)
			state_machine.dispatch(&"to_chase_angry")
		else:
			state_machine.dispatch(&"to_idle")

#What happens when the cube is grabbed
func grab()->void:
	$FlipNode/GrabbableArea/CollisionShape2D.set_deferred("disabled",true)
	$FlipNode/Sprite2D.modulate = Color(0.363, 0.003, 0.023, 1.0)
	velocity.x = 0;
	
#If the ice cube collides with another ice cube or spike at ANY state it should explode
func _on_hurt_area_body_entered(body: Node2D) -> void:
	
	if(not body == self):
		state_machine.dispatch(&"to_death")
		#this ensures that both this cube dies and the other one dies as well
		if(body.is_class("CharacterBody2D")):
			body.death()
	
	pass # Replace with function body.
