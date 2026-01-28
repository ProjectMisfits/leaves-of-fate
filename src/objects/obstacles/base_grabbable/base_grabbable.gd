extends Area2D
class_name BaseGrabbable

#state machine for grabable objects 
@onready var state_machine: LimboHSM = $"../LimboHSM"
@onready var ungrabbed_state: LimboState = $"../LimboHSM/Ungrabbed"
@onready var grabbed_state: LimboState = $"../LimboHSM/Grabbed"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intialize_statemachine()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func intialize_statemachine()-> void:
	
	state_machine.add_transition(ungrabbed_state,grabbed_state,&"to_grabbed")
	state_machine.add_transition(grabbed_state,ungrabbed_state,&"to_ungrabbed")
	
	state_machine.initial_state = ungrabbed_state
	state_machine.initialize(self)
	state_machine.set_active(true)

func rotate_sprite()-> void:
	$"../Sprite2D".rotate(.05)
	
func companion_action_triggered()->void:
	state_machine.get_active_state().companion_action_triggered()

func ungrab()->void:
	state_machine.dispatch(&"to_ungrabbed")
	
func grab()->void:
	state_machine.dispatch(&"to_grabbed")
	
	
