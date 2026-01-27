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
	
#Disable companion collision so that the player can't target it while grabbed
func disable_companion_collision()->void:
	$CollisionShape2D.set_deferred("disabled",true)

#enable companion collision so the player can target it again
func enable_companion_collision()->void:
	$CollisionShape2D.set_deferred("disabled",false)
	
