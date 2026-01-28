extends Enemey
class_name Ice_Scream
#States
@onready var idle_state : LimboState = $LimboHSM/Idle
@onready var chase_normal_state : LimboState = $LimboHSM/ChaseNormal
@onready var chase_angry_state : LimboState = $LimboHSM/ChaseAngry
@onready var grabbed_state : LimboState = $LimboHSM/Grabbed

#Variable keeping track of the players last known position
var player_last_known_pos : Vector2
#Speed when idle
const IDLE_SPEED : float = 10

#Speed when chargin
const CHARGE_SPEED : float = 10
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#The intial direction of the cube
var look_direction : float


func _ready() -> void:
	super()
	look_direction = $FlipNode.scale.x
	
func intialize_statemachine()-> void:
	#Add all the state machine stuff
	state_machine.add_transition(idle_state,chase_normal_state,&"to_chase_normal")
	state_machine.add_transition(chase_normal_state,idle_state,&"to_idle")
	state_machine.add_transition(chase_angry_state,idle_state,&"to_idle")
	state_machine.add_transition(idle_state,grabbed_state,&"to_grabbed")
	state_machine.add_transition(chase_normal_state,grabbed_state,&"to_grabbed")
	
	state_machine.initial_state = idle_state
	super()

func _physics_process(delta: float) -> void:

	#apply gravity at all times
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()


func begin_chase_normal()-> void:
	$FlipNode/Sprite2D.modulate = Color(0.816, 0.346, 0.871, 1.0)
	$WaitBeforeChase.start()

func _on_wait_before_chase_timeout() -> void:
	$FlipNode/Sprite2D.modulate = Color(0.818, 0.114, 0.331, 1.0)
	state_machine.dispatch(&"to_chase_normal")
	pass # Replace with function body.

func check_reached()->void:
	#if its within 5 pixels 
	if abs(player_last_known_pos.x)-abs(global_position.x) < 5 and look_direction ==1:
		state_machine.dispatch(&"to_idle")
	elif abs(global_position.x) - abs(player_last_known_pos.x) < 5 and look_direction == -1:
		state_machine.dispatch(&"to_idle")

func reset()->void:
	$FlipNode/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	velocity.x = 0

func move(delta: float)->void:
	
	move_horizontal(look_direction,CHARGE_SPEED,delta)

func _on_sight_body_entered(body: Node2D) -> void:
	if(state_machine.get_active_state() == idle_state):
		#Player is spoted in idle state chargem
		#If the player is behind the ice cube, flip it then charge
		if(abs(body.global_position.x)-abs(global_position.x) < 0) and look_direction == 1:
			
			flip()
			look_direction = -1
		elif (abs(body.global_position.x)-abs(global_position.x) > 0) and look_direction == -1:
			flip()
			look_direction = 1
		player_last_known_pos = body.global_position
		begin_chase_normal()
	
	pass # Replace with function body.
