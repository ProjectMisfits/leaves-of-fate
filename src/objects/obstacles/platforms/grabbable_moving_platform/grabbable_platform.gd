extends BaseGrabbable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.
	
func companion_action_triggered()->void:
	super()

#Stop the platform 
func stop_platform()->void:
	$"../..".stop_platform()
	state_machine.dispatch(&"to_grabbed")

#Continue the platform 
func continue_platform()->void:
	$"../..".resume_platform()
	state_machine.dispatch(&"to_ungrabbed")
	
