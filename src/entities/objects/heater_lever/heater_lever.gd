class_name HeaterLever extends Decor
## An entity for activating heaters. Only turns heaters on.

## The name of the flag to update.
@export var heater_flag_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	# Set the flag name that this lever's trigger updates to the appropriate name for this heater
	$ObjectTrigger.flag_name = heater_flag_name
