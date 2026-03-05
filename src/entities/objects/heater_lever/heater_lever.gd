class_name HeaterLever extends Decor
## An entity for activating heaters. Only turns heaters on.

## The name of the flag to update.
@export var heater_flag_name: String

## Whether the lever has been turned.
var lever_turned: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	# Set the flag name that this lever's trigger updates to the appropriate name for this heater
	$ObjectTrigger.flag_name = heater_flag_name
	$ObjectTrigger.required_false_event_flags.append(heater_flag_name)
	EventFlags.flag_updated.connect(_turn_lever)

## Turn the lever when the player interacts with it.
func _turn_lever(flag_name: String, flag_value: bool) -> void:
	if flag_name == heater_flag_name and flag_value and not lever_turned:
		lever_turned = true
		$AnimationPlayer.play(&"turn_lever")
