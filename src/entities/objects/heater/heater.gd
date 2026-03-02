class_name Heater extends Decor
## A space heater that the player enables by interacting with something in the world.

## Whether this heater is off.
var heater_off: bool = true

## The name of this heater.
@export var heater_name: String

func _ready() -> void:
	super()
	EventFlags.flag_updated.connect(_on_event_flag_updated)

## Triggered when an event flag is updated. If the flag indicates that a heater should change state, change the state of this heater to match.
func _on_event_flag_updated(flag_name: String, flag_value: bool) -> void:
	if flag_name == heater_name + '_activated' and flag_value and heater_off:
		await get_tree().create_timer(2).timeout
		$AnimationPlayer.play(&"heater_on")
		heater_off = false
