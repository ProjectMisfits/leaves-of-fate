class_name HeaterLever extends Decor
## An entity for activated heaters.

## What number heater this trigger activates.
@export var heater_number: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	# Set the flag name that this lever's trigger updates to the appropriate name for this heater
	$ObjectTrigger.flag_name = "heater_" + str(heater_number) + "_activated"
