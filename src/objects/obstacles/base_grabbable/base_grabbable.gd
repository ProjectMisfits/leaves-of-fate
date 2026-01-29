class_name BaseGrabbable extends Area2D
## An entity that is grabbable by the claw ability.

## The grabbable object's state machine.
@onready var state_machine: LimboHSM = $LimboHSM
## The state machine's ungrabbed state.
@onready var ungrabbed_state: LimboState = $LimboHSM/Ungrabbed
## The state machine's grabbed state.
@onready var grabbed_state: LimboState = $LimboHSM/Grabbed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

## Change the entity's state from grabbed to ungrabbed.
func ungrab() -> void:
	state_machine.dispatch(&"to_ungrabbed")

## Change the entity's state from ungrabbed to grabbed.
func grab() -> void:
	state_machine.dispatch(&"to_grabbed")

## When the entity is ungrabbed, this function will be called by the state machine to show that it is ungrabbed.
func rotate_sprite() -> void:
	$Sprite2D.rotate(.05)
