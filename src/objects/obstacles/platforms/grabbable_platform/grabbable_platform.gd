class_name GrabbablePlatform extends MovingPlatform
## A grabbable moving platform.

## The grabbable object's state machine.
@onready var state_machine: LimboHSM = $LimboHSM
## The state machine's ungrabbed state.
@onready var ungrabbed_state: LimboState = $LimboHSM/Ungrabbed
## The state machine's grabbed state.
@onready var grabbed_state: LimboState = $LimboHSM/Grabbed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_closed_loop_speed = closed_loop_speed
	cur_open_loop_speed_scale = open_loop_speed_scale
	
	initialize_animation()
	initialize_statemachine()

## Initialize the state machine.
func initialize_statemachine()-> void:
	state_machine.add_transition(ungrabbed_state,grabbed_state,&"to_grabbed")
	state_machine.add_transition(grabbed_state,ungrabbed_state,&"to_ungrabbed")
	
	state_machine.initial_state = ungrabbed_state
	state_machine.initialize(self)
	state_machine.set_active(true)

## Use the state machine to toggle states when the claw action is triggered.
func companion_action_triggered() -> void:
	state_machine.get_active_state().companion_action_triggered()

#Stop the platform 
func stop_platform()->void:
	print("stopping platform")
	if closed_loop:
		cur_closed_loop_speed = 0;
	else:
		animation_player.speed_scale = 0
	state_machine.dispatch(&"to_grabbed")

#Resume the platform 
func resume_platform() -> void:
	print("resuming platform")
	if closed_loop:
		cur_closed_loop_speed = closed_loop_speed;
	else:
		animation_player.speed_scale = cur_open_loop_speed_scale
	state_machine.dispatch(&"to_ungrabbed")

#Disable companion collision so that the player can't target it while grabbed
func disable_companion_collision()->void:
	$AnimatableBody2D/CollisionShape2D.set_deferred("disabled", true)

#enable companion collision so the player can target it again
func enable_companion_collision()->void:
	$AnimatableBody2D/CollisionShape2D.set_deferred("disabled", false)
